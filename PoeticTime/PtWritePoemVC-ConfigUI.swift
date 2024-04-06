//
//  PtWritePoemVC-ConfigUI.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/5.
//

import UIKit
import SnapKit

extension PtWritePoemVC {
    
    // 隐藏键盘
    @objc func hideKeyBoard() {
        updatePoemName()
        updatePoemDate()
        writePoemNameView.resignFirstResponder()
        writePoemTextView.resignFirstResponder()
    }
    
    // 设置写诗View页面UI
    func setWriteViewUI() {
        view.addSubview(backButton)
        view.addSubview(flipContentView)
        flipContentView.addSubview(poemContentView)
        flipContentView.addSubview(writeView)
        flipContentView.addSubview(rotationView)
        poemContentView.addSubview(poemImageView)
        poemContentView.addSubview(poemNameLabel)
        poemContentView.addSubview(poemDateTextLabel)
        writeView.addSubview(writePoemNameView)
        writeView.addSubview(writePoemAuthorLabel)
        writeView.addSubview(writePoemTextView)
        view.addSubview(changeImageButton)
        view.addSubview(saveDataButton)
        view.addSubview(unSaveAlertView)
        view.addSubview(deleteButton)
        view.addSubview(checkDeleteView)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(44)
            make.width.height.equalTo(32)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(32)
        }
        
        flipContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23)
            make.right.equalToSuperview().offset(-23)
            make.top.equalToSuperview().offset(137)
            make.height.equalTo(483)
        }
        
        writeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        writePoemNameView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
        
        writePoemAuthorLabel.snp.makeConstraints { make in
            make.top.equalTo(writePoemNameView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        writePoemTextView.snp.makeConstraints { make in
            make.top.equalTo(writePoemAuthorLabel.snp.bottom)
            make.right.bottom.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
        }
        
        poemContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        poemImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(384)
        }
        
        poemNameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(poemImageView.snp.bottom).offset(8)
        }
        
        poemDateTextLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        changeImageButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(110)
            make.height.width.equalTo(61)
            make.top.equalTo(poemContentView.snp.bottom).offset(44)
        }
        
        saveDataButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-110)
            make.height.width.equalTo(61)
            make.top.equalTo(poemContentView.snp.bottom).offset(44)
        }
        
        rotationView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-4)
            make.height.width.equalTo(24)
        }
    }
}


