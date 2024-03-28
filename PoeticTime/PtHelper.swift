//
//  PtHelper.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/23.
//

import UIKit

// 初始化imageView的Rect
let viewInitRect = CGRect(x: 0, y: 0, width: 100, height: 100)

// tabBar高度
let ptTabBarHeight: CGFloat = 120

// cellID
let kPtCardCollectionViewCell = "PtCardCollectionViewCell"
let kPtDynastyCollectionViewCell = "PtDynastyCollectionViewCell"

// UIBounds
let Bounds = UIScreen.main.bounds

// 标准字体
let standardFont = "SJbangkaijianti"

// 系统状态栏高度
var statusBarHeight: Int {
    get {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let statusBarManager = windowScene.statusBarManager {
                let statusBarFrame = statusBarManager.statusBarFrame
                let statusBarHeight = statusBarFrame.height
                return Int(statusBarHeight)
            }
        }
        return 44
    }
}
extension String {
    var pt_argbColor: UIColor? {
        return UIColor(argbString: self)
    }
}

extension UIColor {
    convenience init?(argbString: String) {
        var hexColor = argbString

        // 如果字符串以 '#' 开头，去掉 '#'
        if hexColor.hasPrefix("#") {
            hexColor = String(hexColor.dropFirst())
        }

        // 根据字符串长度决定是解析 RGB 还是 ARGB
        var alpha: CGFloat = 1.0
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0

        if hexColor.count == 6 {
            // RGB
            if let rgbValue = UInt32(hexColor, radix: 16) {
                red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
                green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
                blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            } else {
                return nil
            }
        } else if hexColor.count == 8 {
            // ARGB
            if let argbValue = UInt32(hexColor, radix: 16) {
                alpha = CGFloat((argbValue & 0xFF000000) >> 24) / 255.0
                red = CGFloat((argbValue & 0x00FF0000) >> 16) / 255.0
                green = CGFloat((argbValue & 0x0000FF00) >> 8) / 255.0
                blue = CGFloat(argbValue & 0x000000FF) / 255.0
            } else {
                return nil
            }
        } else {
            return nil
        }

        // 使用 ARGB 分量创建 UIColor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
