//
//  PTTabBar.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/23.
//

import UIKit
import SnapKit

// 自定义tabbar，设置高度
class PtTabBar: UITabBar {
    
    // 学习tab的imageView
    private lazy var tabBarStudyItemImageView: UIImageView = {
        let tabBarStudyItemImageView = UIImageView(frame: viewInitRect)
        tabBarStudyItemImageView.image = UIImage(named: "poetic_time_study_tab_bar")
        tabBarStudyItemImageView.contentMode = .scaleAspectFit
        return tabBarStudyItemImageView
    }()
    
    // 学习tab的Label
    private lazy var tabBarStudyItemLabel: UILabel = {
        let tabBarStudyItemLabel = UILabel()
        tabBarStudyItemLabel.text = "学堂"
        tabBarStudyItemLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 22)
        tabBarStudyItemLabel.textAlignment = .center
        return tabBarStudyItemLabel
    }()
    
    // 学习tab
    private lazy var stackTabStudyView: UIStackView = {
        let stackTabStudyView = UIStackView()
        stackTabStudyView.axis = .vertical
        stackTabStudyView.spacing = 2
        stackTabStudyView.addArrangedSubview(tabBarStudyItemImageView)
        stackTabStudyView.addArrangedSubview(tabBarStudyItemLabel)
        stackTabStudyView.isUserInteractionEnabled = true
        stackTabStudyView.tag = 0
        return stackTabStudyView
    }()
    
    // 扫描tab的imageView
    private lazy var tabBarScanItemImageView: UIImageView = {
        let tabBarStudyItemImageView = UIImageView(frame: viewInitRect)
        tabBarStudyItemImageView.image = UIImage(named: "poetic_time_scan_tab_bar")
        tabBarStudyItemImageView.contentMode = .scaleAspectFit
        return tabBarStudyItemImageView
    }()
    
    // 扫描tab的Label
    private lazy var tabBarScanItemLabel: UILabel = {
        let tabBarScanItemLabel = UILabel()
        tabBarScanItemLabel.text = "斗诗"
        tabBarScanItemLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 22)
        tabBarScanItemLabel.textAlignment = .center
        return tabBarScanItemLabel
    }()
    
    // 扫描tab
    private lazy var stackTabScanView: UIStackView = {
        let stackTabScanView = UIStackView()
        stackTabScanView.axis = .vertical
        stackTabScanView.spacing = 2
        stackTabScanView.addArrangedSubview(tabBarScanItemImageView)
        stackTabScanView.addArrangedSubview(tabBarScanItemLabel)
        stackTabStudyView.tag = 1
        return stackTabScanView
    }()
    
    // 个人tab的imageView
    private lazy var tabBarUserItemImageView: UIImageView = {
        let tabBarStudyItemImageView = UIImageView(frame: viewInitRect)
        tabBarStudyItemImageView.image = UIImage(named: "poetic_time_user_tab_bar")
        tabBarStudyItemImageView.contentMode = .scaleAspectFit
        return tabBarStudyItemImageView
    }()
    
    // 个人tab的Label
    private lazy var tabBarUserItemLabel: UILabel = {
        let tabBarUserItemLabel = UILabel()
        tabBarUserItemLabel.text = "私阁"
        tabBarUserItemLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 22)
        tabBarUserItemLabel.textAlignment = .center
        return tabBarUserItemLabel
    }()
    
    // 个人tab
    private lazy var stackTabUserView: UIStackView = {
        let stackTabUserView = UIStackView()
        stackTabUserView.axis = .vertical
        stackTabUserView.spacing = 2
        stackTabUserView.addArrangedSubview(tabBarUserItemImageView)
        stackTabUserView.addArrangedSubview(tabBarUserItemLabel)
        stackTabStudyView.tag = 2
        return stackTabUserView
    }()
    
    
    /// 切换tabBar
    public func changeSelectTabBarTap(_ tag: Int) {
        // 根据视图的 tag 区分不同的 view
        resetImageAndLabelColor()
        if tag == 0 {
            tabBarStudyItemImageView.image = UIImage(named: "poetic_time_study_select_tab_bar")
            tabBarStudyItemLabel.textColor = .black
        } else if tag == 1 {
            tabBarScanItemImageView.image = UIImage(named: "poetic_time_scan_select_tab_bar")
            tabBarScanItemLabel.textColor = .black
        } else if tag == 2 {
            tabBarUserItemImageView.image = UIImage(named: "poetic_time_user_select_tab_bar")
            tabBarUserItemLabel.textColor = .black
        }
    }
    
    func resetImageAndLabelColor() {
        tabBarStudyItemImageView.image = UIImage(named: "poetic_time_study_tab_bar")
        tabBarStudyItemLabel.textColor = "#CECECE".pt_argbColor
        tabBarScanItemImageView.image = UIImage(named: "poetic_time_scan_tab_bar")
        tabBarScanItemLabel.textColor = "#CECECE".pt_argbColor
        tabBarUserItemImageView.image = UIImage(named: "poetic_time_user_tab_bar")
        tabBarUserItemLabel.textColor = "#CECECE".pt_argbColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 在这里调整高度
        var frame = self.frame
        frame.size.height = ptTabBarHeight // 设置指定高度
        frame.origin.y = self.superview!.frame.size.height - frame.size.height
        self.frame = frame
        self.backgroundColor = .clear
    }
    
    // 添加view并布局
    private func setTabBarItemUI() {
        self.addSubview(stackTabStudyView)
        self.addSubview(stackTabScanView)
        self.addSubview(stackTabUserView)
        
        tabBarStudyItemImageView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        tabBarScanItemImageView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        tabBarUserItemImageView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        stackTabStudyView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(44)
            make.height.equalTo(70)
            make.width.equalTo(50)
        }
        
        stackTabScanView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(70)
            make.width.equalTo(50)
        }
        
        stackTabUserView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-44)
            make.height.equalTo(70)
            make.width.equalTo(50)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTabBarItemUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
