//
//  PtWritePoemVC-Logic.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/5.
//

import UIKit

extension PtWritePoemVC {
    // 取消退出
    func cancelHandle() {
        unSaveAlertView.isHidden = true
        changeAllButtonState()
    }
    
    // 确认退出
    func confirmHandle() {
        hero.dismissViewController { [weak self] in
            guard let self = self else { return }
            self.reloadTableView()
        }
    }
    
    // 改变所有按钮状态
    func changeAllButtonState() {
        deleteButton.isEnabled.toggle()
        backButton.isEnabled.toggle()
        saveDataButton.isEnabled.toggle()
        changeImageButton.isEnabled.toggle()
        writePoemNameView.isEnabled.toggle()
        writePoemTextView.isEditable.toggle()
    }
    
    // 更新诗词时间
    func updatePoemDate() {
        poemDateTextLabel.text = getDateString(userPoemDate: Date().timeIntervalSince1970)
    }
    
    // 删除操作
    @objc func deleteHandle() {
        changeAllButtonState()
        checkDeleteView.isHidden = false
    }
    
    // 取消删除
    func cancelDeleteHandle() {
        checkDeleteView.isHidden = true
        changeAllButtonState()
    }
    
    // 确认删除
    func confirmDeleteHandle() {
        let info = DBInfo()
        info.tableType = .userPoem
        info.userPoemId = userPoemId
        PoeticTimeDao.deleteElement(info: info) { [weak self] in
            guard let self = self else { return }
            self.hero.dismissViewController { [weak self] in
                guard let self = self else { return }
                // 从数据库读取
                PoeticTimeDao.readData()
                self.reloadTableView()
            }
        }
    }
    
    // 更新诗词名
    func updatePoemName() {
        poemNameLabel.text = writePoemNameView.text == "" ? writePoemNameView.placeholder : writePoemNameView.text
    }
    
    // 更新内存中的数据
    func updateMemoryData() {
        userPoemDate = Date().timeIntervalSince1970
        userPoemName = (writePoemNameView.text?.count == 0 ? writePoemNameView.placeholder ?? "" : writePoemNameView.text) ?? ""
        userPoemBody = writePoemTextView.text ?? ""
        if let data = poemImageView.image?.pngData() {
            userPoemImageData = data
        }
    }
    
    // 保存数据到数据库
    func saveData() {
        if userPoemData.contains(where: { userPoem in
            userPoem.userPoemId == self.userPoemId
        }) {
            let info = DBInfo(userPoemId: userPoemId, userPoemName: userPoemName, userPoemDate: userPoemDate, userPoemDynasty: userPoemDynasty, userPoemBody: userPoemBody, userPoemImageData: userPoemImageData)
            PoeticTimeDao.updateElement(info: info)
        } else {
            let info = DBInfo(userPoemId: userPoemId, userPoemName: userPoemName, userPoemDate: userPoemDate, userPoemDynasty: userPoemDynasty, userPoemBody: userPoemBody, userPoemImageData: userPoemImageData)
            PoeticTimeDao.insertElement(info: info)
        }
        // 从数据库读取
        PoeticTimeDao.readData()
    }
    
    // 保存按钮执行操作
    @objc func saveHandle(sender: UIButton) {
        ButtonAnimate(sender)
        updateMemoryData()
        saveData()
        isChanged = false
    }
    
    // 翻转View
    @objc func flipView() {
        hideKeyBoard()
        if isFlipped {
            // 如果已经翻转，则执行反向翻转动画
            UIView.transition(from: writeView, to: poemContentView, duration: 1.0, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
        } else {
            // 如果未翻转，则执行正向翻转动画
            UIView.transition(from: poemContentView, to: writeView, duration: 1.0, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
        }
        // 轻微震动
        lightFeedBack()
        // 切换翻转状态
        isFlipped = !isFlipped
    }
    
    // dimiss当前View
    @objc func dismissCurrentVC() {
        request?.cancel()
        if isChanged {
            // 重量级震动
            weightFeedBack()
            changeAllButtonState()
            unSaveAlertView.isHidden = false
            unSaveAlertView.alertText = "当前修改未保存，是否继续退出?"
            unSaveAlertView.confirmText = "继续退出?"
            unSaveAlertView.updateAlertUI()
            unSaveAlertView.confirmHandle = self.confirmHandle
            unSaveAlertView.cancelHandle = self.cancelHandle
        } else {
            hero.dismissViewController { [weak self] in
                guard let self = self else { return }
                self.reloadTableView()
            }
        }
    }
}
