//
//  DynastyVC-ScrollView.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/30.
//

import UIKit

extension DynastyVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.infoScrollView {
            self.currentPage = Int(scrollView.contentOffset.x / Bounds.width)
        } else if scrollView == self.dynastyStoryContentView {
            let currentPage = Int(scrollView.contentOffset.x / dynastyStoryContentView.frame.width)
            guard let pageControl = pageControl else { return }
            pageControl.currentPage = currentPage
        }
    }
    
    // 内部scrollView的控制器
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        let targetOffsetX = CGFloat(sender.currentPage) * dynastyStoryContentView.frame.width
        dynastyStoryContentView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
    }
    
    // 控制器切换页面操作
    @objc func changeInfoView(_ sender: UIButton) {
        // tag不能设置为0，会被系统认为未设置标签
        let index = sender.tag - 1
        self.currentPage = index
    }
    
    // pageControl点击后的联动
    func pageControlValueChanged() {
        let targetOffsetX = CGFloat(self.currentPage) * Bounds.width
        infoScrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
        // tag不能设置为0，会被系统认为未设置标签
        guard let viewWithTag = self.view.viewWithTag(currentPage + 1) as? UIButton else { return }
        clearSelected()
        viewWithTag.setTitleColor(.black, for: .normal)
    }
    
    // 清除点击效果
    func clearSelected() {
        dynastyStoryButton.setTitleColor(.white, for: .normal)
        diyPoemButton.setTitleColor(.white, for: .normal)
        poemListButton.setTitleColor(.white, for: .normal)
    }
}
