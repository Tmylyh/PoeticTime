//
//  PoetDetailVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/30.
//

import UIKit
import Hero
import SnapKit

class PoetDetailVC: UIViewController {
    
    var poetName = ""
    
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "poetic_time_back_image"), for: .normal)
        backButton.addTarget(self, action: #selector(dismissCurrentVC), for: .touchUpInside)
        return backButton
    }()
    
    // dimiss当前View
    @objc func dismissCurrentVC() {
        hero.dismissViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(44)
            make.height.width.equalTo(32)
        }
    }
}
