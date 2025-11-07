//
//  Extensions.swift
//  APP
//
//  扩展集合 - 包含项目中的所有扩展
//

import Foundation
import UIKit

// MARK: - Bundle 扩展

extension Bundle {
    /// 应用名称
    var appName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
               object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? ""
    }
    
    /// 应用版本号
    var appVersion: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    /// 构建版本号
    var buildNumber: String {
        return object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "1"
    }
    
    /// 带版本信息的应用名称
    var appNameWithVersion: String {
        return "\(appName) v\(appVersion) (Build \(buildNumber))"
    }
    
    /// 应用图标文件名
    var iconFileName: String? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let iconFileName = iconFiles.first {
            return "\(iconFileName)@2x.png"
        }
        return nil
    }
}

// MARK: - FileManager 扩展

extension FileManager {
    // MARK: 目录管理
    
    /// 创建目录（如果不存在）
    /// - Parameters:
    ///   - url: 目录URL
    ///   - createIntermediates: 是否创建中间目录
    func createDirectoryIfNeeded(at url: URL, withIntermediateDirectories createIntermediates: Bool = true) throws {
        if !fileExists(atPath: url.path) {
            try createDirectory(at: url, withIntermediateDirectories: createIntermediates)
        }
    }
    
    /// 获取目录中的文件路径
    /// - Parameters:
    ///   - directory: 目录URL
    ///   - file: 文件名
    /// - Returns: 完整文件路径URL（如果存在）
    func getPath(in directory: URL, for file: String) -> URL? {
        let fileURL = directory.appendingPathComponent(file)
        return fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    // MARK: 文件操作
    
    /// 删除文件（如果存在）
    /// - Parameter url: 文件URL
    func removeFileIfNeeded(at url: URL) throws {
        if fileExists(atPath: url.path) {
            try removeItem(at: url)
        }
    }
    
    // MARK: 应用目录
    
    /// 文档目录
    var documents: URL {
        return urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// 库目录
    var library: URL {
        return urls(for: .libraryDirectory, in: .userDomainMask).first!
    }
    
    /// 缓存目录
    var caches: URL {
        return urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    /// 临时目录
    var temporary: URL {
        return temporaryDirectory
    }
    
    // MARK: 应用特定路径
    
    /// 未签名文件目录
    var unsigned: URL {
        return documents.appendingPathComponent("Unsigned", isDirectory: true)
    }
    
    /// 已签名文件目录
    var signed: URL {
        return documents.appendingPathComponent("Signed", isDirectory: true)
    }
}

// MARK: - String 本地化扩展

extension String {
    /// 本地化字符串
    /// - Parameter comment: 翻译注释
    /// - Returns: 本地化后的字符串
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    /// 本地化字符串（快捷方式）
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: - UIViewController 弹窗扩展

extension UIViewController {
    /// 显示带取消按钮的弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息内容
    ///   - style: 弹窗样式
    ///   - actions: 自定义操作按钮
    static func showAlertWithCancel(
        title: String,
        message: String,
        style: UIAlertController.Style = .alert,
        actions: [UIAlertAction] = []
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: style
        )
        
        for action in actions {
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(cancelAction)
        
        // 获取最顶层的视图控制器
        if var topController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true)
        }
    }
    
    /// 显示简单提示
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息内容
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Date 格式化扩展

extension Date {
    /// 格式化日期字符串
    /// - Parameter format: 日期格式（默认：yyyy-MM-dd HH:mm:ss）
    /// - Returns: 格式化后的日期字符串
    func formattedString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// MARK: - UIColor 扩展

extension UIColor {
    /// 使用十六进制颜色代码创建颜色
    /// - Parameter hex: 十六进制颜色代码（支持格式：#RRGGBB 或 RRGGBB）
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
