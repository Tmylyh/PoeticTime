//
//  PtSettingVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/6.
//

import UIKit

class PtSettingVC: UITableViewController {
    
    lazy var alertView: PtAlertView = {
        let alertView = PtAlertView(frame: viewInitRect)
        alertView.alertText = "是否清空所有数据？"
        alertView.cancelText = "取消"
        alertView.confirmText = "确定清空"
        alertView.isHidden = true
        alertView.cancelHandle = cancelHandle
        alertView.confirmHandle = confirmHandle
        return alertView
    }()
    
    // 执行完成后的回调
    var completion: (() -> Void)?
    
    func cancelHandle() {
        alertView.isHidden = true
    }
    
    func confirmHandle() {
        alertView.isHidden = true
        // 清空数据
        PoeticTimeDao.deleteAll()
        deleteUserInfoData()
        // 初始化数据
        PoeticTimeDao.initDB()
        initUserData()
        initUserInfoData()
        // 读取数据
        PoeticTimeDao.readData()
        readUserInfoData()
        completion?()
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(alertView)
        
        // 注册可重用单元格
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kPtSettingCellID)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kPtSettingCellID, for: indexPath)
        cell.textLabel?.text = "数据初始化"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        alertView.isHidden = false
    }
}
