//
//  PtDataHelper.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/4.
//

import UIKit

// 初始化用户数据
func initUserData() {
    // 初始化个人作诗数据
    let image = UIImage(named: initUserPoemImageName)
    for dynastyName in dynastyNameData {
        let info = DBInfo()
        info.tableType = .userPoem
        info.userPoemId = "\(UUID())"
        // TODO: -@lyh 不同朝代的诗名，包括上面的照片
        info.userPoemName = initUserPoemName
        info.userPoemBody = initUserPoemBody
        if let data = image?.jpegData(compressionQuality: 1.0) {
            info.userPoemImageData = data
        }
        info.userPoemDynasty = dynastyName
        info.userPoemDate = Date().timeIntervalSince1970
        PoeticTimeDao.insertElement(info: info)
        PoeticTimeDao.readData()
    }
}
