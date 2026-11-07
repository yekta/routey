import Foundation

/// DNS asked of a public resolver through the server over TCP, so the local network's DNS (which
/// may lie about blocked names) is never asked, and it works on servers without UDP.
///
/// Every query shares one connection, as DNS over TCP allows: each goes out under an ID of its
/// own, so answers can come back in any order, and the app's ID is put back on its answer. When
/// the connection closes or breaks, the next query opens another, and the queries still waiting
/// are asked again there. It closes itself once nothing has been asked for a while.
public final class DNSResolver {
    public static let resolver = Address(name: "1.1.1.1", port: 53)
    private static let timeout: TimeInterval = 8
    private static let idleTimeout: TimeInterval = 20
    /// How many connections one query may be asked on.
    private static let attempts = 2

    private let upstream: Upstream
    private let target: Address
    private let queue = DispatchQueue(label: "dns-resolver")
    private var tunnel: StreamTunnel?
    private var buffer = Data()
    private var pending: [UInt16: Query] = [:]
    private var nextID = UInt16.random(in: .min ... .max)
    private var lastActivity = Date()
    private var timer: DispatchSourceTimer?

    private struct Query {
        let originalID: Data
        let message: Data
        let asked: Date
        var attempts: Int
        let completion: (Data?) -> Void
    }

    public init(upstream: Upstream, resolver: Address = DNSResolver.resolver) {
        self.upstream = upstream
        target = resolver
    }

    deinit {
        timer?.cancel()
        tunnel?.cancel()
    }

    /// Calls `completion` once, on a queue of the resolver's, with the answer, or nil if there is
    /// none.
    public func resolve(_ query: Data, completion: @escaping (Data?) -> Void) {
        queue.async { [self] in
            guard query.count >= 12, query.count <= 0xFFFF else { return completion(nil) }
            guard let id = freeID() else { return completion(nil) }
            var message = Data(query)
            message.replaceSubrange(0..<2, with: [UInt8(id >> 8), UInt8(id & 0xFF)])
            pending[id] = Query(originalID: Data(query.prefix(2)), message: message, asked: Date(), attempts: 1, completion: completion)
            lastActivity = Date()
            startTimer()
            send(Self.framed(message))
        }
    }

    /// Closes the connection; the queries waiting get no answer.
    public func cancel() {
        queue.async { [self] in
            timer?.cancel()
            timer = nil
            closeTunnel()
            let waiting = pending.values
            pending.removeAll()
            for query in waiting {
                query.completion(nil)
            }
        }
    }

    private func freeID() -> UInt16? {
        guard pending.count < Int(UInt16.max) else { return nil }
        while pending[nextID] != nil {
            nextID &+= 1
        }
        defer { nextID &+= 1 }
        return nextID
    }

    /// Over the open connection, or a new one that sends it along with its request.
    private func send(_ data: Data) {
        if let tunnel {
            return tunnel.send(data) { _ in }
        }
        let tunnel = upstream.stream(to: target, queue: queue)
        self.tunnel = tunnel
        buffer = Data()
        tunnel.onFailure = { [weak self, weak tunnel] _ in
            guard let self, let tunnel else { return }
            self.lost(tunnel)
        }
        tunnel.start(sending: data)
        receive(from: tunnel)
    }

    private func receive(from tunnel: StreamTunnel) {
        tunnel.receive { [weak self, weak tunnel] result in
            guard let self, let tunnel, tunnel === self.tunnel else { return }
            guard case let .success(data?) = result else { return self.lost(tunnel) }
            self.buffer.append(data)
            while let message = Self.message(in: self.buffer) {
                self.buffer = Data(self.buffer.dropFirst(2 + message.count))
                self.answered(Data(message))
            }
            self.receive(from: tunnel)
        }
    }

    private func answered(_ message: Data) {
        guard message.count >= 12 else { return }
        let id = UInt16(message[message.startIndex]) << 8 | UInt16(message[message.startIndex + 1])
        guard let query = pending.removeValue(forKey: id) else { return }
        lastActivity = Date()
        var answer = message
        answer.replaceSubrange(answer.startIndex..<answer.startIndex + 2, with: query.originalID)
        query.completion(answer)
    }

    /// The connection closed or broke: the queries still waiting are asked again on a new one,
    /// those already asked on as many as they may get no answer.
    private func lost(_ tunnel: StreamTunnel) {
        guard tunnel === self.tunnel else { return }
        closeTunnel()
        var retry = Data()
        for (id, query) in pending.sorted(by: { $0.value.asked < $1.value.asked }) {
            guard query.attempts < Self.attempts else {
                pending[id] = nil
                query.completion(nil)
                continue
            }
            pending[id]?.attempts += 1
            retry.append(Self.framed(query.message))
        }
        if !retry.isEmpty {
            send(retry)
        }
    }

    private func closeTunnel() {
        tunnel?.onFailure = nil
        tunnel?.cancel()
        tunnel = nil
        buffer = Data()
    }

    /// Gives up on queries unanswered for too long, and closes the connection once it is idle.
    private func startTimer() {
        guard timer == nil else { return }
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 1, repeating: 1)
        timer.setEventHandler { [weak self] in self?.tick() }
        timer.resume()
        self.timer = timer
    }

    private func tick() {
        let now = Date()
        for (id, query) in pending where now.timeIntervalSince(query.asked) > Self.timeout {
            pending[id] = nil
            query.completion(nil)
        }
        guard pending.isEmpty, now.timeIntervalSince(lastActivity) > Self.idleTimeout else { return }
        closeTunnel()
        timer?.cancel()
        timer = nil
    }

    /// DNS over TCP puts each message after its length.
    static func framed(_ message: Data) -> Data {
        var data = Data([UInt8(message.count >> 8), UInt8(message.count & 0xFF)])
        data.append(message)
        return data
    }

    /// The first whole message in `data`, if it has arrived.
    static func message(in data: Data) -> Data? {
        guard data.count >= 2 else { return nil }
        let length = Int(data[data.startIndex]) << 8 | Int(data[data.startIndex + 1])
        guard data.count >= 2 + length else { return nil }
        return data.dropFirst(2).prefix(length)
    }
}
