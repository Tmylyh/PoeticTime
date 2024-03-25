//
//  ViewController.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/20.
//

import UIKit

class HomeTabBarVC: UITabBarController {
    
    // 子视图控制器
    let studyVC = StudyVC()
    let scanVC = ScanVC()
    let userVC = UserVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // 使用自定义tabBar
        let tabBar = PtTabBar()
        tabBar.changeSelectTabBar = changeSelectTabBar
        self.setValue(tabBar, forKey: "tabBar")
        configTabBarVC()
    }
    
    // 配制tabbar
    func configTabBarVC() {

        // 配制子vc
        studyVC.tabBarItem.tag = 0
        scanVC.tabBarItem.tag = 1
        userVC.tabBarItem.tag = 2
        
        // 导航栏
        let nav1 = UINavigationController(rootViewController: studyVC)
        let nav2 = UINavigationController(rootViewController: scanVC)
        let nav3 = UINavigationController(rootViewController: userVC)
        viewControllers = [nav1, nav2, nav3]

        //配制前景色
        tabBar.barTintColor = .white
        // 配制底色
        tabBar.backgroundColor = .white
    }
    
    private func changeSelectTabBar(tag: Int) {
        self.selectedIndex = tag
    }
}


