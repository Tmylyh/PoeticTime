//
//  UserVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/20.
//

import UIKit
import DBSphereTagCloudSwift

class UserVC: UIViewController {
    
    var sphereView: DBSphereView!
    override func viewDidLoad() {
        super.viewDidLoad()
        sphereView = DBSphereView(frame: CGRect(x: 30, y: 100, width: 320, height: 320))
        var array = [UIButton]()

        for i in 1..<50 {
            let btn = UIButton(type: UIButton.ButtonType.system)
            btn.setTitle("\(i)", for: .normal)
            btn.setTitleColor(.darkGray, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.light)
            btn.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
            btn.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
            array.append(btn)
            sphereView.addSubview(btn)
        }
        sphereView.setCloudTags(array)
        sphereView.backgroundColor = .white
        self.view.addSubview(sphereView)
    }
    
    @objc func buttonTapped() {
        print(123)
    }

}
