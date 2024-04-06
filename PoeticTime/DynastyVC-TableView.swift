//
//  DynastyVC-TableView.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/3.
//

import UIKit

extension DynastyVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 多出一个cell，让可滚动范围变大，不让按钮挡住cell
        return userPoemCurrentData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < userPoemCurrentData.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: kDynastyUserPoemCell, for: indexPath) as? DynastyUserPoemCell else { return UITableViewCell()}
            // 设置cell的selectionStyle属性为.none,去掉点击后的hightlight效果
            cell.selectionStyle = .none
            cell.initData(index: indexPath.row, userPoemCurrentData: userPoemCurrentData)
            return cell
        } else {
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: Bounds.width, height: 76))
            cell.backgroundColor = .clear
            cell.isUserInteractionEnabled = false
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        ButtonAnimate(cell)
        let writePoemVC = PtWritePoemVC()
        cell.hero.id = "writePoem\(indexPath.row)"
        writePoemVC.isFromInsert = false
        writePoemVC.userPoemName = userPoemCurrentData[indexPath.row].userPoemName
        writePoemVC.userPoemImageData = userPoemCurrentData[indexPath.row].userPoemImageData
        writePoemVC.userPoemDynasty = userPoemCurrentData[indexPath.row].userPoemDynasty
        writePoemVC.userPoemId = userPoemCurrentData[indexPath.row].userPoemId
        writePoemVC.userPoemBody = userPoemCurrentData[indexPath.row].userPoemBody
        writePoemVC.userPoemDate = userPoemCurrentData[indexPath.row].userPoemDate
        writePoemVC.userName = userInfo.userName
        writePoemVC.reloadTableView = tableViewDataReload
        writePoemVC.view.hero.id = "writePoem\(indexPath.row)"
        writePoemVC.hero.isEnabled = true
        writePoemVC.modalPresentationStyle = .overFullScreen
        present(writePoemVC, animated: true)
    }
}
