import Foundation
import Network
import NetworkExtension
import os
import ProxyCore

/// macOS hands this every new outgoing connection. The chosen apps' go through the Shadowsocks
/// server and, with VLESS on, every other app's go through the VLESS server; the rest are handed
/// straight back and never pass through here.
@objc(TransparentProxyProvider)
final class TransparentProxyProvider: NETransparentProxyProvider, NEAppProxyUDPFlowHandling {
    private let state = OSAllocatedUnfairLock(initialState: State())

    private struct State {
        var config = ProxyConfig()
        var shadowsocks: Server?
        var vless: VLESSServer?
        /// Each server's one connection for DNS.
        var shadowsocksDNS: DNSResolver?
        var vlessDNS: DNSResolver?
        var relays: [ObjectIdentifier: AnyObject] = [:]
        var stats = ProxyStats()
    }

    override func startProxy(options: [String: Any]? = nil, completionHandler: @escaping (Error?) -> Void) {
        let saved = (protocolConfiguration as? NETunnelProviderProtocol)?.providerConfiguration?["config"] as? Data
        apply(saved.flatMap { try? JSONDecoder().decode(ProxyConfig.self, from: $0) } ?? ProxyConfig())

        let settings = NETransparentProxyNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        settings.includedNetworkRules = [
            NENetworkRule(remoteNetworkEndpoint: nil, remotePrefix: 0, localNetworkEndpoint: nil, localPrefix: 0, protocol: .any, direction: .outbound),
        ]
        setTunnelNetworkSettings(settings, completionHandler: completionHandler)
    }

    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        let relays = state.withLock { state in
            defer { state.relays.removeAll() }
            return Array(state.relays.values)
        }
        for relay in relays {
            (relay as? Closable)?.close()
        }
        let resolvers = state.withLock { state in
            defer {
                state.shadowsocksDNS = nil
                state.vlessDNS = nil
            }
            return [state.shadowsocksDNS, state.vlessDNS]
        }
        resolvers.forEach { $0?.cancel() }
        completionHandler()
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)? = nil) {
        guard let message = try? JSONDecoder().decode(ProviderMessage.self, from: messageData) else {
            completionHandler?(nil)
            return
        }
        switch message {
        case .stats:
            completionHandler?(try? JSONEncoder().encode(state.withLock { $0.stats }))
        case let .config(config):
            apply(config)
            completionHandler?(nil)
        }
    }

    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
        guard let route = upstream(for: flow) else { return false }
        let upstream = route.0
        if let udp = flow as? NEAppProxyUDPFlow {
            return relay(udp, through: route)
        }
        guard let tcp = flow as? NEAppProxyTCPFlow,
              let target = Address(tcp.remoteFlowEndpoint), !target.isLocal else { return false }
        let relay = TCPRelay(flow: tcp, target: target, upstream: upstream, events: self)
        retain(relay, kind: upstream.kind)
        relay.start()
        return true
    }

    func handleNewUDPFlow(_ flow: NEAppProxyUDPFlow, initialRemoteFlowEndpoint remoteEndpoint: Network.NWEndpoint) -> Bool {
        // DNS is taken even to the local network: the router's answers may be false.
        guard let target = Address(remoteEndpoint), !target.isLocal || target.port == 53 else { return false }
        return relay(flow, through: upstream(for: flow))
    }

    private func relay(_ flow: NEAppProxyUDPFlow, through route: (Upstream, DNSResolver)?) -> Bool {
        guard let (upstream, dns) = route else { return false }
        let relay = UDPRelay(flow: flow, upstream: upstream, dns: dns, events: self)
        retain(relay, kind: upstream.kind)
        relay.start()
        return true
    }

    /// The server a flow goes through, and its connection for DNS.
    private func upstream(for flow: NEAppProxyFlow) -> (Upstream, DNSResolver)? {
        let identifier = flow.metaData.sourceAppSigningIdentifier
        return state.withLock { state in
            guard let upstream = state.config.upstream(for: identifier, shadowsocks: state.shadowsocks, vless: state.vless),
                  let dns = upstream.kind == .shadowsocks ? state.shadowsocksDNS : state.vlessDNS else { return nil }
            return (upstream, dns)
        }
    }

    private func apply(_ config: ProxyConfig) {
        let shadowsocks = try? Server(link: config.shadowsocks.server)
        let vless = try? VLESSServer(link: config.vless.server)
        let replaced = state.withLock { state in
            let replaced = [state.shadowsocksDNS, state.vlessDNS]
            state.config = config
            state.shadowsocks = shadowsocks
            state.vless = vless
            state.shadowsocksDNS = shadowsocks.map { DNSResolver(upstream: .shadowsocks($0)) }
            state.vlessDNS = vless.map { DNSResolver(upstream: .vless($0)) }
            return replaced
        }
        replaced.forEach { $0?.cancel() }
    }

    private func retain(_ relay: AnyObject, kind: UpstreamKind) {
        state.withLock { state in
            state.relays[ObjectIdentifier(relay)] = relay
            state.stats[kind].connections += 1
        }
    }
}

protocol Closable: AnyObject {
    func close()
}

/// What relays report back: bytes moved, failures, and when they are done.
protocol RelayEvents: AnyObject {
    func relayed(_ kind: UpstreamKind, sent: Int, received: Int)
    func relayFailed(_ kind: UpstreamKind, _ error: Error)
    func relayClosed(_ relay: AnyObject, kind: UpstreamKind)
}

extension TransparentProxyProvider: RelayEvents {
    func relayed(_ kind: UpstreamKind, sent: Int, received: Int) {
        state.withLock { state in
            state.stats[kind].sent += UInt64(sent)
            state.stats[kind].received += UInt64(received)
            if received > 0 {
                state.stats[kind].lastError = nil
            }
        }
    }

    func relayFailed(_ kind: UpstreamKind, _ error: Error) {
        state.withLock { $0.stats[kind].lastError = error.localizedDescription }
    }

    func relayClosed(_ relay: AnyObject, kind: UpstreamKind) {
        state.withLock { state in
            guard state.relays.removeValue(forKey: ObjectIdentifier(relay)) != nil else { return }
            state.stats[kind].connections -= 1
        }
    }
}
