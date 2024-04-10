//
//  UserVC-ConfigUI.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/5.
//

import UIKit
import SnapKit

extension UserVC {
    // 配制页面UI
    func setUserViewUI() {
        // 上面多了一个navigationBar
        navigationController?.navigationBar.isUserInteractionEnabled = false
        view.backgroundColor = "#ADADAD".pt_argbColor
        view.addSubview(backgroundImageView)
        view.addSubview(backTapView)
        view.addSubview(userImageView)
        view.addSubview(userName)
        view.addSubview(userInfoName)
        view.addSubview(settingButton)
        view.addSubview(userPoemButton)
        view.addSubview(starPoemButton)
        view.addSubview(listScrollView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backTapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        settingButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(54)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(44)
        }
        
        userImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(70)
            make.width.height.equalTo(106)
        }
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        
        userName.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        userInfoName.snp.makeConstraints { make in
            make.top.equalTo(userName.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        userPoemButton.snp.makeConstraints { make in
            make.top.equalTo(userInfoName.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(Bounds.width / 2 - 96)
            make.width.equalTo(96)
            make.height.equalTo(34)
        }
        
        starPoemButton.snp.makeConstraints { make in
            make.top.equalTo(userInfoName.snp.bottom).offset(8)
            make.left.equalTo(userPoemButton.snp.right).offset(-1)
            make.width.equalTo(96)
            make.height.equalTo(34)
        }
    }
    
    // 配制infoView的子View
    func setListSubViewUI() {
        listSubViews.append(userPoemTableView)
        listSubViews.append(starPoemListCollectionView)
        for (index, view) in listSubViews.enumerated() {
            view.frame = CGRect(x: index * Int(Bounds.width), y: 0, width: Int(Bounds.width), height: Int(listScrollView.frame.height - ptTabBarHeight))
            listScrollView.addSubview(view)
        }
        listScrollView.addSubview(tipsWriteView)
        tipsWriteView.frame = CGRect(x: Int(Bounds.width / 2 - 130), y: 60, width: 260, height: 30)
        listScrollView.addSubview(tipsStarView)
        tipsStarView.frame = CGRect(x: Int(Bounds.width + Bounds.width / 2 - 130), y: 60, width: 260, height: 30)
    }
}
