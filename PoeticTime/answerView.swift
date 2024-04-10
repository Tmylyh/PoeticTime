//
//  answerView.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/10.
//

import UIKit
import SnapKit

class answerView: UIView {
    
    // 结果
    var completion: ((String) -> Void)?

    lazy var answerLabel: UITextField = {
        let answerLabel = UITextField()
        answerLabel.placeholder = "请输入你的答案"
        answerLabel.textColor = .black
        answerLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 18)
        answerLabel.returnKeyType = .done
        answerLabel.delegate = self
        return answerLabel
    }()

    override func layoutSubviews() {
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.addSubview(answerLabel)
        
        answerLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalToSuperview()
        }
    }
}

extension answerView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        completion?(textField.text ?? "")
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
}
