import Foundation
import Network

@available(iOS 12.0, *)
final class CellularChecker {

    struct Result {
        let cellularInterfaceAvailable: Bool   // passive check
        let cellularDataReachable: Bool        // active check
    }

    // Single serial queue: all handlers + timeouts run here,
    // so the `didComplete` flags are race-free without locks.
    private let queue = DispatchQueue(label: "cellular.checker.queue")

    /// Runs the passive check, then (only if the interface exists) the active check.
    func check(host: String = "www.apple.com",
               port: UInt16 = 443,
               timeout: TimeInterval = 5.0,
               completion: @escaping (Result) -> Void) {

        passiveCheck(timeout: 2.0) { [weak self] interfaceAvailable in
            guard let self = self else { return }

            // No cellular interface at all → skip the active check.
            guard interfaceAvailable else {
                completion(Result(cellularInterfaceAvailable: false,
                                  cellularDataReachable: false))
                return
            }

            self.activeCheck(host: host, port: port, timeout: timeout) { reachable in
                completion(Result(cellularInterfaceAvailable: true,
                                  cellularDataReachable: reachable))
            }
        }
    }

    // MARK: - Passive: is a cellular path available?

    private func passiveCheck(timeout: TimeInterval,
                              completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor(requiredInterfaceType: .cellular)
        var didComplete = false

        let finish: (Bool) -> Void = { available in
            guard !didComplete else { return }
            didComplete = true
            monitor.cancel()
            completion(available)
        }

        monitor.pathUpdateHandler = { path in
            finish(path.status == .satisfied)
        }

        // Safety net in case the monitor never reports.
        queue.asyncAfter(deadline: .now() + timeout) { finish(false) }

        monitor.start(queue: queue)
    }

    // MARK: - Active: actually reach a host over cellular

    private func activeCheck(host: String,
                             port: UInt16,
                             timeout: TimeInterval,
                             completion: @escaping (Bool) -> Void) {

        let params = NWParameters.tls
        params.requiredInterfaceType = .cellular            // pin THIS connection to cellular
        params.prohibitedInterfaceTypes = [.wifi, .wiredEthernet, .loopback] // no silent fallback

        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            completion(false)
            return
        }

        let connection = NWConnection(host: NWEndpoint.Host(host),
                                      port: nwPort,
                                      using: params)

        var didComplete = false
        let finish: (Bool) -> Void = { result in
            guard !didComplete else { return }
            didComplete = true
            connection.cancel()
            completion(result)
        }

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:              finish(true)   // reached host over cellular
            case .failed, .cancelled: finish(false)
            default:                  break
            }
        }

        queue.asyncAfter(deadline: .now() + timeout) { finish(false) }

        connection.start(queue: queue)
    }
}