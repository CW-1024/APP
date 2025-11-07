import Foundation
import os.log

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Nuke)
import Nuke
#endif

class MemorySafety {
    static let shared = MemorySafety()
    private let logger = Logger(subsystem: "com.feather.app", category: "MemorySafety")
    
    private init() {}
    
    func cleanup(aggressive: Bool = false) {
        logger.info("Performing memory cleanup")
        
        // Clear caches
        #if canImport(Nuke)
        ImagePipeline.shared.cache.removeAll()
        #endif
        
        if aggressive {
            // More aggressive cleanup
            URLCache.shared.removeAllCachedResponses()
            
            #if canImport(Nuke)
            // Clear any other caches if needed
            if let cache = ImagePipeline.shared.configuration.dataCache as? DataCache {
                cache.removeAll()
            }
            #endif
        }
        
        // Notify the system we've freed up memory
        if aggressive {
            logger.info("Requesting memory warning simulation")
            #if canImport(UIKit)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
            }
            #endif
        }
    }
}

// MARK: - Safe Autorelease Pool
enum SafeAutoreleasePool {
    static func execute(_ block: @escaping () -> Void) {
        autoreleasepool {
            block()
        }
    }
}

// MARK: - UIApplication Extensions
#if canImport(UIKit)
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
#endif
