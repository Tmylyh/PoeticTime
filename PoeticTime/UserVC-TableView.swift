//
//  User-TableView.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/5.
//

import UIKit

extension UserVC: UITableViewDelegate, UITableViewDataSource {
    
    // 重新加载数据
    func tableViewDataReload() {
        userPoemTableView.reloadData()
        // 更新提示文本显示状态
        if userPoemData.count == 0 {
            tipsWriteView.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPoemData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kDynastyUserPoemCell, for: indexPath) as? DynastyUserPoemCell else { return UITableViewCell()}
        // 设置cell的selectionStyle属性为.none,去掉点击后的hightlight效果
        cell.selectionStyle = .none
        cell.isFromUserVC = true
        cell.initData(index: indexPath.row, userPoemCurrentData: userPoemData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        ButtonAnimate(cell)
        let writePoemVC = PtWritePoemVC()
        let uniqueUUID = "\(UUID())"
        cell.hero.id = "userVCUserPoemList\(uniqueUUID)"
        writePoemVC.isFromInsert = false
        writePoemVC.userPoemName = userPoemData[indexPath.row].userPoemName
        writePoemVC.userPoemImageData = userPoemData[indexPath.row].userPoemImageData
        writePoemVC.userPoemDynasty = userPoemData[indexPath.row].userPoemDynasty
        writePoemVC.userPoemId = userPoemData[indexPath.row].userPoemId
        writePoemVC.userPoemBody = userPoemData[indexPath.row].userPoemBody
        writePoemVC.userPoemDate = userPoemData[indexPath.row].userPoemDate
        writePoemVC.userName = userInfo.userName
        writePoemVC.reloadTableView = tableViewDataReload
        writePoemVC.view.hero.id = "userVCUserPoemList\(uniqueUUID)"
        writePoemVC.hero.isEnabled = true
        writePoemVC.modalPresentationStyle = .overFullScreen
        present(writePoemVC, animated: true)
    }
}
