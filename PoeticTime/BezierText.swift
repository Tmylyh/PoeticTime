//
//  BezierText.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/30.
//

import UIKit
 
class BezierText: UIView {
     
    // 字迹动画时间
    private var duration: TimeInterval = 5
     
    // 字迹书写图层
    let pathLayer = CAShapeLayer()
    
    // dimiss当前View
    var dismissAnimationBlock: (() -> Void)?
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        //初始化字迹图层
        pathLayer.frame = self.bounds
        //一个布尔值，指示图层及其子层的几何形状是否垂直翻转。
        pathLayer.isGeometryFlipped = true
        pathLayer.fillColor = UIColor.clear.cgColor
        pathLayer.lineWidth = 0.8
        pathLayer.strokeColor = UIColor.white.cgColor

        self.layer.addSublayer(pathLayer)
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    //动态书写指定文字
    func show(text: String) {
        //获取文字对应的贝塞尔曲线
        let textPath = bezierPathFrom(string: text)
         
        //让文字居中显示
        pathLayer.bounds = textPath.cgPath.boundingBox
        //设置笔记书写路径
        pathLayer.path = textPath.cgPath
         
        //添加笔迹书写动画
        let textAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        textAnimation.duration = duration
        textAnimation.fromValue = 0
        textAnimation.toValue = 1
        
        // 事务开始
        CATransaction.begin()

       
        // 动画完成后的回调函数
        // CATransaction原子性管理动画的执行，要么全部完成，要么全部取消
        CATransaction.setCompletionBlock {
            // 在这里处理动画完成后的逻辑
            self.pathLayer.fillColor = UIColor.white.cgColor
            // dismiss页面
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAnimationHandle))
            self.addGestureRecognizer(tapGesture)
        }
        pathLayer.add(textAnimation, forKey: "strokeEnd")
        // 提交事务
        CATransaction.commit()
    }
    
    @objc func dismissAnimationHandle() {
        guard let dismissAnimationBlock = dismissAnimationBlock else { return }
        dismissAnimationBlock()
    }
     
    //将字符串转为贝塞尔曲线
    private func bezierPathFrom(string:String) -> UIBezierPath{
        let fontSize: CGFloat = 64 // 字体大小
        let paths = CGMutablePath()
        let fontName = __CFStringMakeConstantString(ZiTi.yuweij.rawValue)!
        let fontRef:AnyObject = CTFontCreateWithName(fontName, fontSize, nil)
        let paragraphStyle = NSMutableParagraphStyle()
        let attributes: [NSAttributedString.Key: Any] = [
            kCTFontAttributeName as NSAttributedString.Key : fontRef,
            .paragraphStyle: paragraphStyle,
        ]
        let attrString = NSAttributedString(string: string, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attrString as CFAttributedString)
        let runA = CTLineGetGlyphRuns(line)
        // 第几行
        var currentLine = 0
        // 循环遍历文本行的字形运行
        for runIndex in 0..<CFArrayGetCount(runA) {
            let run = CFArrayGetValueAtIndex(runA, runIndex);
            let runb = unsafeBitCast(run, to: CTRun.self)
            
            let CTFontName = unsafeBitCast(kCTFontAttributeName,
                                           to: UnsafeRawPointer.self)
            
            let runFontC = CFDictionaryGetValue(CTRunGetAttributes(runb),CTFontName)
            let runFontS = unsafeBitCast(runFontC, to: CTFont.self)
            
            // 宽度
            let width = self.frame.width

            // 计算一行文字的高度
            let lineHeight: CGFloat = fontSize + 5
            
            // 偏移量，关于当前View和字必须统一边界的偏移量，如果不写这个逻辑，字有可能出发点不在view的边界
            var offset = 0.0
            
            // 记录第一个字的x值
            var firstX: CGFloat = 0.0
            
            // 只对第一个字形判断偏移量
            var isOnce = true
            
            // 行数
            var temp = 0
            
            
            
            var stringIndices = [CFIndex](repeating: 0, count: CTRunGetGlyphCount(runb))
            CTRunGetStringIndices(runb, CFRangeMake(0, 0), &stringIndices)
            
            for i in 0..<CTRunGetGlyphCount(runb) {
                let range = CFRangeMake(i, 1)
                let glyph = UnsafeMutablePointer<CGGlyph>.allocate(capacity: 1)
                glyph.initialize(to: 0)
                let position = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
                position.initialize(to: .zero)
                CTRunGetGlyphs(runb, range, glyph)
                CTRunGetPositions(runb, range, position);
                 
                let temp3 = CGFloat(position.pointee.x)
                let temp2 = (Int) (temp3 / width)
                let temp1 = 0
                // 第一次执行循环
                if isOnce {
                    // 判断是否超过容器x边界
                    if temp3 < self.frame.minX {
                        offset = self.frame.minX - temp3
                    }
                    firstX = temp3 + offset
                    isOnce = false
                }
                
                // 发生了换行
                if temp2 > temp1 {
                    temp = temp2
                    if temp != currentLine {
                        let glyphIndex = stringIndices[i]
                        let char = string[string.index(string.startIndex, offsetBy: glyphIndex)]
                        // 防止标点符号出现在句子开头
                        if char == "。" || char == "，" {
                            continue
                        }
                        // 保证每行行首和第一行行首对齐
                        offset = firstX - (position.pointee.x - (CGFloat(temp) * width))
                        currentLine = temp
                    }
                }
                
                if let path = CTFontCreatePathForGlyph(runFontS,glyph.pointee,nil) {
                    // 调x和y
                    let x = position.pointee.x - (CGFloat(temp) * width) + offset
                    let y = position.pointee.y - (CGFloat(temp) * lineHeight)
                    let transform = CGAffineTransform(translationX: x, y: y).rotated(by: .pi / 2)
                    paths.addPath(path, transform: transform)
                }
            }
        }
         
        let bezierPath = UIBezierPath()
        bezierPath.move(to: .zero)
        bezierPath.append(UIBezierPath(cgPath: paths))
        duration = TimeInterval(currentLine * 4)
        return bezierPath
    }
}

