//
//  PtAlertView.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/5.
//

import UIKit
import SnapKit

class PtAlertView: UIView {
    
    // 警告文本
    public var alertText = ""
    // 取消文本
    public var cancelText = ""
    // 确定文本
    public var confirmText = ""
    
    // 取消操作
    public lazy var cancelHandle: () -> Void = {}
    // 确认操作
    public lazy var confirmHandle: () -> Void = {}
    
    // 更新UI操作
    public func updateAlertUI() {
        alertLabel.text = alertText
        cancelButton.setTitle(cancelText, for: .normal)
        confirmButton.setTitle(confirmText, for: .normal)
    }
    
    // 文本
    private lazy var alertLabel: UILabel = {
        let alertLabel = UILabel()
        alertLabel.text = alertText
        alertLabel.textColor = .black
        alertLabel.textAlignment = .center
        alertLabel.numberOfLines = 0
        alertLabel.font = .systemFont(ofSize: 16)
        return alertLabel
    }()
    
    // 取消
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.backgroundColor = .tertiaryLabel
        cancelButton.setTitle(cancelText, for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        cancelButton.layer.cornerRadius = 20
        cancelButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        cancelButton.layer.masksToBounds = true
        cancelButton.addTarget(self, action: #selector(cancelButtonTap), for: .touchUpInside)
        return cancelButton
    }()
    
    // 继续
    private lazy var confirmButton: UIButton = {
        let confirmButton = UIButton()
        confirmButton.backgroundColor = .tertiaryLabel
        confirmButton.setTitle(confirmText, for: .normal)
        confirmButton.setTitleColor(.red, for: .normal)
        confirmButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        confirmButton.layer.cornerRadius = 20
        confirmButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        confirmButton.layer.masksToBounds = true
        confirmButton.addTarget(self, action: #selector(confirmButtonTap), for: .touchUpInside)
        return confirmButton
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(alertLabel)
        self.addSubview(cancelButton)
        self.addSubview(confirmButton)
        
        self.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(160)
            make.width.equalTo(260)
        }
        
        alertLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-16)
            make.left.right.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(130)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.left.equalTo(cancelButton.snp.right)
            make.height.equalTo(cancelButton.snp.height)
        }
    }
    
    @objc private func cancelButtonTap() {
        cancelHandle()
    }
    
    @objc private func confirmButtonTap() {
        confirmHandle()
    }
}
