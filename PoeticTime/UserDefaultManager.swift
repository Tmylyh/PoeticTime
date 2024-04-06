//
//  UserDefaultManager.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/6.
//

import UIKit

/// 读用户数据
func readUserInfoData() {
    if let data = UserDefaults.standard.data(forKey: kUserInfoKey) {
        if let tmpUserInfo = try? JSONDecoder().decode(UserInfo.self, from: data){
            userInfo = tmpUserInfo
        }else{
            debugPrint("用户数据解码失败")
        }
    }
}

/// 存用户数据
func saveUserInfoData() {
    do {
      let data = try JSONEncoder().encode(userInfo)
        UserDefaults.standard.set(data, forKey: kUserInfoKey)//由于是Todo类型所以无法存进plist文件，需转data类型，用json编码
    } catch {
        debugPrint("用户数据编码错误")
    }
}

/// 删除用户数据
func deleteUserInfoData() {
    // 从 UserDefaults 中移除指定键的数据
    UserDefaults.standard.removeObject(forKey: kUserInfoKey)
}

/// 初始化用户数据
func initUserInfoData() {
    let image = UIImage(named: initUserImageName) ?? UIImage()
    if let data = image.pngData() {
        userInfo = UserInfo(userName: initUserName, userIntro: initUserIntro, userImageData: data)
    }
    saveUserInfoData()
}
