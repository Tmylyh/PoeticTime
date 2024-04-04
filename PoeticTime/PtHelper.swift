//
//  PtHelper.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/23.
//

import UIKit

/// 字体枚举
enum ZiTi: String {
    case pmzd = "PangMenZhengDao-Cu"
    case sjbkjt = "SJbangkaijianti"
    case yuweij = "yuweij"
}

/// 网络状态
var isReachable: Bool = true

/// 每个字符后添加换行符，使文字纵向排列
func verticalText(text: String) -> String {
    var vText = ""
    for (index, char) in text.enumerated() {
        if index < text.count - 1 {
            vText += "\(char)\n"
        } else {
            vText += "\(char)"
        }
    }
    return vText
}

/// 清理历史对话
func clearRequest() {
    // 1. 准备请求的 URL
    guard let url = URL(string: "\(chatURL)/chat/clear") else {
        return
    }

    // 3. 准备请求
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // 4. 发送请求
    let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
        guard error == nil else {
            debugPrint("Error: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
    }

    // 启动请求任务
    task.resume()
}

/// 循环遍历字体
func printZiTi() {
    for familyName in UIFont.familyNames {
        print("familyName: '\(familyName)'")
        for fontName in UIFont.fontNames(forFamilyName: familyName) {
            print("  fontName: '\(fontName)'")
        }
        print("***********")
    }
}

/// 按钮动画
func ButtonAnimate(_ sender: UIView){
    UIView.animate(withDuration: 0.25, animations: {
        sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }) { (finished) in
        UIView.animate(withDuration: 0.25) {
            sender.transform = CGAffineTransform.identity
        }
    }
}

/// collectionView滑动动画
func moveAnimationWithCollectionView(collectionView: UICollectionView) {
    let cells = collectionView.visibleCells
    for cell in cells {
        // 初始时将 cell 平移到底部，即完全不可见的位置
        cell.transform = CGAffineTransform(translationX: 0, y: 400)
        
        let indexPath = collectionView.indexPath(for: cell)!
        // 执行动画效果，将 cell 移动到原本的位置
        UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.item), usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            cell.transform = .identity
        }, completion: nil)
    }
}

/// 日期转换
func getDateString(userPoemDate: Double) -> String {
    // 获取当前时间的时间戳（单位：秒）
    let currentTimestamp = userPoemDate

    // 创建一个 DateFormatter 实例来定义日期格式
    let dateFormatter = DateFormatter()

    // 设置日期格式为 "yyyy-MM-dd"
    dateFormatter.dateFormat = "yyyy-MM-dd"

    // 将时间戳转换为日期对象
    let date = Date(timeIntervalSince1970: currentTimestamp)

    // 使用 DateFormatter 格式化日期为字符串
    let formattedDate = dateFormatter.string(from: date)
    return formattedDate
}

/// tabelView加载动画
func moveAnimationWithTableView(tableView: UITableView) {
    let cells = tableView.visibleCells
    for i in 0..<cells.count {
        let totalTime: TimeInterval = 1
        let cell = tableView.visibleCells[i]
        cell.transform = CGAffineTransform(translationX: 0, y: 400)
        UIView.animate(withDuration: 1, delay: TimeInterval(i) * (totalTime / Double(cells.count)), usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            cell.transform = .identity
        }, completion: { finished in
            // 做点什么
        })
    }
}

/// 手机重量级震动
func weightFeedBack() {
    // 重量级触碰
    let generator = UINotificationFeedbackGenerator()
    // 确保震动反馈能够准备就绪并在调用 impactOccurred() 时表现最佳
    generator.prepare()
    // 执行震动
    generator.notificationOccurred(.success) // 选择震动类型，这里选择成功的反馈
}

/// 手机轻量级震动
func lightFeedBack() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    // 确保震动反馈能够准备就绪并在调用 impactOccurred() 时表现最佳
    generator.prepare()
    generator.impactOccurred()
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
