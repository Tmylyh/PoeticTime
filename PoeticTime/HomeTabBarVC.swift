//
//  ViewController.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/20.
//

import UIKit

class HomeTabBarVC: UITabBarController, UINavigationControllerDelegate {
    
    // 子视图控制器
    let studyVC = StudyVC()
    let scanVC = ScanVC()
    let userVC = UserVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // 使用自定义tabBar
        let tabBar = PtTabBar()
        self.setValue(tabBar, forKey: "tabBar")
        configTabBarVC()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let tabBar = tabBar as? PtTabBar else { return }
        tabBar.changeSelectTabBarTap(item.tag)
        
        // 执行动画
        self.userVC.userPoemTableView.isHidden = true
        if item.tag == 2 {
            // 执行某个操作
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                moveAnimationWithTableView(tableView: self.userVC.userPoemTableView)
                self.userVC.userPoemTableView.isHidden = false
            }
            userVC.reloadCurrentVC()
        }
    }
    
    // 配制tabbar
    func configTabBarVC() {
        
        // 导航栏
        let nav1 = UINavigationController(rootViewController: studyVC)
        let nav2 = UINavigationController(rootViewController: scanVC)
        let nav3 = UINavigationController(rootViewController: userVC)
        // 配制子vc
        nav1.tabBarItem.tag = 0
        nav2.tabBarItem.tag = 1
        nav3.tabBarItem.tag = 2
        viewControllers = [nav1, nav2, nav3]

        //配制前景色
        tabBar.barTintColor = .white
        // 配制底色
        tabBar.backgroundColor = .white
        
        // 初始化选中tag
        guard let tabBar = tabBar as? PtTabBar else { return }
        tabBar.changeSelectTabBarTap(0)
    }
}


