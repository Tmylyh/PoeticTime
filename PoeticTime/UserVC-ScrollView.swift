//
//  UserVC-ScrollView.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/5.
//

import UIKit

extension UserVC: UIScrollViewDelegate {
    
    // 控制器切换页面操作
    @objc func changeInfoView(_ sender: UIButton) {
        // tag不能设置为0，会被系统认为未设置标签
        let index = sender.tag - 1
        self.currentPage = index
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.listScrollView {
            self.currentPage = Int(scrollView.contentOffset.x / Bounds.width)
        }
    }
    
    // 清除点击效果
    func clearSelected() {
        userPoemButton.setTitleColor("#B0B0B0".pt_argbColor, for: .normal)
        userPoemButton.backgroundColor = .white
        starPoemButton.setTitleColor("#B0B0B0".pt_argbColor, for: .normal)
        starPoemButton.backgroundColor = .white
    }
    
    // pageControl点击后的联动
    func pageControlValueChanged() {
        let targetOffsetX = CGFloat(self.currentPage) * Bounds.width
        listScrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
        // tag不能设置为0，会被系统认为未设置标签
        guard let viewWithTag = self.view.viewWithTag(currentPage + 1) as? UIButton else { return }
        clearSelected()
        viewWithTag.setTitleColor(.white, for: .normal)
        viewWithTag.backgroundColor = "#000000".pt_argbColor
        
        if currentPage == 0 {
            starPoemListCollectionView.isHidden = true
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // tableView动画
                moveAnimationWithTableView(tableView: self.userPoemTableView)
                self.userPoemTableView.isHidden = false
            }
        } else if currentPage == 1 {
            // collectionView动画
            userPoemTableView.isHidden = true
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                moveAnimationWithCollectionView(collectionView: self.starPoemListCollectionView)
                self.starPoemListCollectionView.isHidden = false
            }
        }
        // 滑动回顶部
        // 溢出判断
        if userPoemTableView.visibleCells.count > 0 {
            userPoemTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        if starPoemListCollectionView.visibleCells.count > 0 {
            starPoemListCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}
