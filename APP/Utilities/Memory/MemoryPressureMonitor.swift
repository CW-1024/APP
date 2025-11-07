import Foundation
import os.log

class MemoryPressureMonitor {
    static let shared = MemoryPressureMonitor()
    private let logger = Logger(subsystem: "com.feather.app", category: "MemoryPressureMonitor")
    
    private init() {
        setupMemoryPressureMonitor()
    }
    
    private func setupMemoryPressureMonitor() {
        let monitor = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .global())
        monitor.setEventHandler { [weak self] in
            self?.handleMemoryPressure(monitor.data)
        }
        monitor.resume()
    }
    
    private func handleMemoryPressure(_ event: DispatchSource.MemoryPressureEvent) {
        switch event {
        case .warning:
            logger.warning("Memory pressure warning received")
            MemorySafety.shared.cleanup()
        case .critical:
            logger.critical("Memory pressure critical received")
            MemorySafety.shared.cleanup(aggressive: true)
        default:
            break
        }
    }
}
