//
//  PtWritePoemVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/4.
//

import UIKit
import SnapKit

class PtWritePoemVC: UIViewController {
    
    // 标记视图是否翻转
    var isFlipped = false
    
    // 用户写的诗id
    var userPoemId = ""
    // 用户写的诗名
    var userPoemName = initUserPoemName
    // 用户写的诗日期
    var userPoemDate: Double = Date().timeIntervalSince1970
    // 用户写的诗朝代
    var userPoemDynasty = ""
    // 用户写的诗主体
    var userPoemBody = initUserPoemBody
    // 用户名
    var userName = ""
    // 诗词照片
    var userPoemImageData: Data = Data()
    
    // 是否发生了更新
    var isChanged: Bool = false
    
    // 是否来自新增按钮
    var isFromInsert: Bool = false
    
    // 更新外部tableView
    lazy var reloadTableView: () -> Void = {}
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "poetic_time_back_white_image"), for: .normal)
        backButton.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(dismissCurrentVC), for: .touchUpInside)
        return backButton
    }()
    
    // 翻转View容器
    lazy var flipContentView: UIView = {
        let flipContentView = UIView(frame: viewInitRect)
        flipContentView.backgroundColor = .clear
        return flipContentView
    }()
    
    // 内容容器
    lazy var poemContentView: UIView = {
        let poemContentView = UIView(frame: viewInitRect)
        poemContentView.backgroundColor = .white
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipView))
        poemContentView.addGestureRecognizer(tapGesture)
        return poemContentView
    }()
    
    // 诗的照片
    lazy var poemImageView: UIImageView = {
        let poemImageView = UIImageView(frame: viewInitRect)
        poemImageView.image = UIImage(named: "poetic_time_write_poem_image")
        poemImageView.contentMode = .scaleAspectFit
        return poemImageView
    }()
    
    // 诗名
    lazy var poemNameLabel: UILabel = {
        let poemNameLabel = UILabel()
        poemNameLabel.text = userPoemName
        poemNameLabel.textColor = .black
        poemNameLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 24)
        return poemNameLabel
    }()
    
    // 诗的日期
    lazy var poemDateTextLabel: UILabel = {
        let poemDateTextLabel = UILabel()
        poemDateTextLabel.textColor = .black
        poemDateTextLabel.text = getDateString(userPoemDate: userPoemDate)
        poemDateTextLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 24)
        return poemDateTextLabel
    }()
    
    // 写诗的View
    lazy var writeView: UIView = {
        let writeView = UIView(frame: viewInitRect)
        writeView.isHidden = true
        writeView.backgroundColor = .white
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipView))
        writeView.addGestureRecognizer(tapGesture)
        return writeView
    }()
    
    // 写诗的诗名
    lazy var writePoemNameView: UITextField = {
        let writePoemNameView = UITextField()
        if userPoemName == initUserPoemName {
            writePoemNameView.placeholder = userPoemName
        } else {
            writePoemNameView.text = userPoemName
        }
        writePoemNameView.textAlignment = .center
        writePoemNameView.delegate = self
        writePoemNameView.returnKeyType = .done
        writePoemNameView.font = UIFont(name: ZiTi.pmzd.rawValue, size: 24)
        return writePoemNameView
    }()
    
    // 写诗的作者
    lazy var writePoemAuthorLabel: UILabel = {
        let writePoemAuthorLabel = UILabel()
        writePoemAuthorLabel.text = userName
        writePoemAuthorLabel.textColor = .black
        writePoemAuthorLabel.textAlignment = .center
        writePoemAuthorLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 18)
        return writePoemAuthorLabel
    }()
    
    // 写诗的主体
    lazy var writePoemTextView: UITextView = {
        let writePoemTextView = UITextView(frame: viewInitRect)
        writePoemTextView.text = userPoemBody
        writePoemTextView.textColor = .black
        writePoemTextView.delegate = self
        writePoemTextView.font = UIFont(name: ZiTi.pmzd.rawValue, size: 24)
        return writePoemTextView
    }()
    
    // 旋转按钮
    lazy var rotationView: UIImageView = {
        let rotationView = UIImageView(frame: viewInitRect)
        rotationView.image = UIImage(named: "poetic_time_write_poem_rotation_image")
        rotationView.backgroundColor = .clear
        return rotationView
    }()
    
    // 更换图片按钮
    lazy var changeImageButton: UIButton = {
        let changeImageButton = UIButton()
        changeImageButton.backgroundColor = .white
        changeImageButton.setImage(UIImage(named: "poetic_time_write_poem_change_image_image"), for: .normal)
        changeImageButton.layer.cornerRadius = 20
        changeImageButton.addTarget(self, action: #selector(changeImageHandle), for: .touchUpInside)
        return changeImageButton
    }()
    
    // 保存按钮
    lazy var saveDataButton: UIButton = {
        let saveDataButton = UIButton()
        saveDataButton.backgroundColor = .white
        saveDataButton.setImage(UIImage(named: "poetic_time_write_poem_save_image"), for: .normal)
        saveDataButton.layer.cornerRadius = 20
        saveDataButton.addTarget(self, action: #selector(saveHandle), for: .touchUpInside)
        return saveDataButton
    }()
    
    // 未保存弹出View
    lazy var unSaveAlertView: PtAlertView = {
        let unSaveAlertView = PtAlertView(frame: viewInitRect)
        unSaveAlertView.backgroundColor = .white
        unSaveAlertView.isHidden = true
        unSaveAlertView.layer.cornerRadius = 20
        unSaveAlertView.layer.borderColor = UIColor.black.cgColor
        unSaveAlertView.layer.borderWidth = 2
        unSaveAlertView.alertText = "当前修改未保存，是否继续退出？"
        unSaveAlertView.cancelText = "取消"
        unSaveAlertView.confirmText = "确认退出"
        unSaveAlertView.cancelHandle = cancelHandle
        unSaveAlertView.confirmHandle = confirmHandle
        return unSaveAlertView
    }()
    
    // 删除按钮
    lazy var deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.backgroundColor = .clear
        deleteButton.isHidden = isFromInsert
        deleteButton.setImage(UIImage(named: "poetic_time_write_poem_delete_image"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteHandle), for: .touchUpInside)
        return deleteButton
    }()
    
    // 确认删除弹出View
    lazy var checkDeleteView: PtAlertView = {
        let checkDeleteView = PtAlertView(frame: viewInitRect)
        checkDeleteView.backgroundColor = .white
        checkDeleteView.isHidden = true
        checkDeleteView.layer.cornerRadius = 20
        checkDeleteView.layer.borderColor = UIColor.black.cgColor
        checkDeleteView.layer.borderWidth = 2
        checkDeleteView.alertText = "删除将永远丢失，是否确认删除？"
        checkDeleteView.cancelText = "取消"
        checkDeleteView.confirmText = "确认删除"
        checkDeleteView.cancelHandle = cancelDeleteHandle
        checkDeleteView.confirmHandle = confirmDeleteHandle
        return checkDeleteView
    }()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        self.view.addGestureRecognizer(tap)
        view.backgroundColor = "#0E3036".pt_argbColor
        setWriteViewUI()
        // 如果是新增赋予一个ID
        if isFromInsert {
            self.userPoemId = "\(UUID())"
        }
        // 赋予图片
        poemImageView.image = UIImage(data: userPoemImageData)
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
    
    // 更新诗词名
    func updatePoemName() {
        poemNameLabel.text = writePoemNameView.text == "" ? writePoemNameView.placeholder : writePoemNameView.text
    }
    
    // 更新内存中的数据
    func updateMemoryData() {
        userPoemDate = Date().timeIntervalSince1970
        userPoemName = (writePoemNameView.text?.count == 0 ? writePoemNameView.placeholder ?? "" : writePoemNameView.text) ?? ""
        userPoemBody = writePoemTextView.text ?? ""
        if let data = poemImageView.image?.jpegData(compressionQuality: 1.0) {
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
    
    // 选择照片
    @objc func changeImageHandle(sender: UIButton) {
        ButtonAnimate(sender)
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
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
    
    // 隐藏键盘
    @objc func hideKeyBoard() {
        updatePoemName()
        updatePoemDate()
        writePoemNameView.resignFirstResponder()
        writePoemTextView.resignFirstResponder()
    }
    
    // dimiss当前View
    @objc func dismissCurrentVC() {
        if isChanged {
            // 重量级震动
            weightFeedBack()
            changeAllButtonState()
            unSaveAlertView.isHidden = false
        } else {
            hero.dismissViewController { [weak self] in
                guard let self = self else { return }
                self.reloadTableView()
            }
        }
    }
}

extension PtWritePoemVC: UITextFieldDelegate, UITextViewDelegate {
    // 当用户按下 Return 键时调用
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 取消 textField 的第一响应者状态，即结束编辑
        if textField.text == "" {
            textField.text = textField.placeholder
        }
        textField.resignFirstResponder()
        updatePoemName()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 内容有变更
        isChanged = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        isChanged = true
        return true
    }
}

extension PtWritePoemVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            poemImageView.image = image
        }
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.isChanged = true
        }
    }
}
