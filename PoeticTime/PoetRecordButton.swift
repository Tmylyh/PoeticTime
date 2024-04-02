//
//  PoetRecordButton.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/2.
//

import UIKit

class PoetRecordButton: UIButton {
    
    lazy var moveCompletion: (Bool) -> Void = { _ in }
    
    // 触摸移动事件处理函数
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        // 检查是否有触摸事件
        guard let touch = touches.first else { return }
        
        // 获取手指在按钮父视图中的位置
        let touchPoint = touch.location(in: self.superview)
        
        // 将触摸点转换为按钮的坐标系
        let touchPointInButton = self.convert(touchPoint, from: self.superview)
        
        // 检查触摸点是否在按钮的范围内
        if self.bounds.contains(touchPointInButton) {
            // 手指在按钮范围内
            moveCompletion(true)
        } else {
            // 手指不在按钮范围内
            moveCompletion(false)
        }
    }
}
