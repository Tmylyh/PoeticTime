//
//  UserVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/20.
//

import UIKit

class UserVC: UIViewController {
    
    // 收藏的诗词卡片集合
    var starPoemData: [Poem] = []
    
    // listView的子视图集合
    var listSubViews: [UIView] = []
    
    // 当前页面
    var _currentPage: Int = 0
    
    // 页面的计算属性，实现pageControl和View联动
    var currentPage: Int {
        get {
            return _currentPage
        }
        set {
            _currentPage = newValue
            pageControlValueChanged()
        }
    }
    
    // 设置按钮
    lazy var settingButton: UIButton = {
        let settingButton = UIButton()
        settingButton.setImage(UIImage(named: "poetic_time_set_image"), for: .normal)
        settingButton.addTarget(self, action: #selector(presentSettingVC), for: .touchUpInside)
        return settingButton
    }()
    
    // 用来点击隐藏键盘的View
    lazy var backTapView: UIView = {
        let backTapView = UIView()
        backTapView.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        backTapView.addGestureRecognizer(tap)
        return backTapView
    }()
    
    // 头像View
    lazy var userImageView: UIImageView = {
        let userImageView = UIImageView(frame: viewInitRect)
        userImageView.image = UIImage(data: userInfo.userImageData)
        userImageView.layer.masksToBounds = true
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor.black.cgColor
        userImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeImageHandle))
        userImageView.addGestureRecognizer(tap)
        return userImageView
    }()
    
    // 用户名
    lazy var userName: UITextField = {
        let userName = UITextField()
        userName.text = userInfo.userName
        userName.textColor = .black
        userName.delegate = self
        userName.returnKeyType = .done
        userName.font = UIFont(name: ZiTi.pmzd.rawValue, size: 24)
        userName.textAlignment = .center
        return userName
    }()
    
    // 座右铭
    lazy var userInfoName: UITextField = {
        let userInfoName = UITextField()
        if userInfo.userIntro == initUserIntro || userInfo.userIntro.count == 0 {
            userInfoName.placeholder = initUserIntro
        } else {
            userInfoName.text = userInfo.userIntro
        }
        userInfoName.textColor = .black
        userInfoName.delegate = self
        userInfoName.returnKeyType = .done
        userInfoName.font = UIFont(name: ZiTi.pmzd.rawValue, size: 16)
        return userInfoName
    }()
    
    // 个人诗词按钮
    lazy var userPoemButton: UIButton = {
        let userPoemButton = UIButton()
        userPoemButton.setTitle("吾诗札", for: .normal)
        userPoemButton.setTitleColor(.white, for: .normal)
        userPoemButton.titleLabel?.font = .systemFont(ofSize: 12)
        userPoemButton.backgroundColor = "#258780".pt_argbColor
        userPoemButton.layer.cornerRadius = 16
        userPoemButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        userPoemButton.layer.masksToBounds = true
        userPoemButton.layer.borderWidth = 1
        userPoemButton.tag = 1
        userPoemButton.layer.borderColor = "#258780".pt_argbColor?.cgColor
        userPoemButton.addTarget(self, action: #selector(changeInfoView), for: .touchUpInside)
        return userPoemButton
    }()
    
    // 收藏诗词按钮
    lazy var starPoemButton: UIButton = {
        let starPoemButton = UIButton()
        starPoemButton.setTitle("藏诗筒", for: .normal)
        starPoemButton.setTitleColor("#B0B0B0".pt_argbColor, for: .normal)
        starPoemButton.titleLabel?.font = .systemFont(ofSize: 12)
        starPoemButton.backgroundColor = .clear
        starPoemButton.layer.cornerRadius = 16
        starPoemButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        starPoemButton.layer.masksToBounds = true
        starPoemButton.layer.borderWidth = 1
        starPoemButton.tag = 2
        starPoemButton.layer.borderColor = "#258780".pt_argbColor?.cgColor
        starPoemButton.addTarget(self, action: #selector(changeInfoView), for: .touchUpInside)
        return starPoemButton
    }()
    
    // 滑动ScrollView
    lazy var listScrollView: UIScrollView = {
        let listScrollView = UIScrollView(frame: CGRect(x: 0, y: 300, width: Int(Bounds.width), height: Int(Bounds.height - 300)))
        listScrollView.backgroundColor = .white
        // 使用页面控制器
        listScrollView.isPagingEnabled = true
        
        listScrollView.layer.cornerRadius = 16
        listScrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        listScrollView.layer.masksToBounds = true
        // 禁止边界弹性滚动
        listScrollView.bounces = false
        // 设置滚动视图范围
        listScrollView.contentSize = CGSize(width: Bounds.width * 2, height: 0)
        // 禁止滚动视图的滚动条
        listScrollView.showsHorizontalScrollIndicator = false
        listScrollView.showsVerticalScrollIndicator = false
        listScrollView.delegate = self
        return listScrollView
    }()
    
    // 个人诗词TableView
    lazy var userPoemTableView: UITableView = {
        let userPoemTableView = UITableView(frame: viewInitRect)
        userPoemTableView.backgroundColor = .white
        // 去掉cell 之间的横线
        userPoemTableView.separatorStyle = .none
        userPoemTableView.showsVerticalScrollIndicator = false
        userPoemTableView.showsHorizontalScrollIndicator = false
        userPoemTableView.delegate = self
        userPoemTableView.dataSource = self
        userPoemTableView.register(DynastyUserPoemCell.self, forCellReuseIdentifier: kDynastyUserPoemCell)
        return userPoemTableView
    }()
    
    // 收藏诗词列表
    lazy var starPoemListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let starPoemListCollectionView = UICollectionView(frame: viewInitRect, collectionViewLayout: layout)
        starPoemListCollectionView.backgroundColor = .white
        starPoemListCollectionView.delegate = self
        starPoemListCollectionView.dataSource = self
        starPoemListCollectionView.contentInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        starPoemListCollectionView.showsVerticalScrollIndicator = false
        starPoemListCollectionView.register(PtPoemCell.self, forCellWithReuseIdentifier: kPtPoemCell)
        starPoemListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return starPoemListCollectionView
    }()
    
    // 提示作诗
    lazy var tipsWriteView: UILabel = {
        let tipsWriteView = UILabel()
        tipsWriteView.text = "诗藏未丰，待君撰写"
        tipsWriteView.textColor = .black
        tipsWriteView.textAlignment = .center
        tipsWriteView.isHidden = true
        tipsWriteView.font = UIFont(name: ZiTi.pmzd.rawValue, size: 24)
        return tipsWriteView
    }()
    
    // 提示收藏
    lazy var tipsStarView: UILabel = {
        let tipsStarView = UILabel()
        tipsStarView.text = "诗藏未丰，待君寻觅"
        tipsStarView.textColor = .black
        tipsStarView.textAlignment = .center
        tipsStarView.isHidden = true
        tipsStarView.font = UIFont(name: ZiTi.pmzd.rawValue, size: 24)
        return tipsStarView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserViewUI()
        setListSubViewUI()
        setData()
        if userPoemData.count == 0 {
            tipsWriteView.isHidden = false
        }
        if starPoemData.count == 0 {
            tipsStarView.isHidden = false
        }
    }
    
    // 重载当前VC
    func reloadCurrentVC() {
        userImageView.image = UIImage(data: userInfo.userImageData)
        userName.text = userInfo.userName
        if userInfo.userIntro == initUserIntro || userInfo.userIntro.count == 0 {
            userInfoName.placeholder = initUserIntro
        } else {
            userInfoName.text = userInfo.userIntro
        }
        setData()
        tableViewDataReload()
        starPoemListCollectionView.reloadData()
        if userPoemData.count == 0 {
            tipsWriteView.isHidden = false
        }
        if starPoemData.count == 0 {
            tipsStarView.isHidden = false
        }
    }
    
    // present设置页面
    @objc func presentSettingVC(sender: UIButton) {
        ButtonAnimate(sender)
        let settingVC = PtSettingVC()
        settingVC.completion = reloadCurrentVC
        self.present(settingVC, animated: true)
    }
    
    // 设置数据
    func setData() {
        starPoemData = poemData.filter {
            $0.poemStar == true
        }
        starPoemData.sort { poem1, poem2 in
            poem1.dynastyId < poem2.dynastyId
        }
    }
    
    // 保存用户数据
    func saveData() {
        let image = userImageView.image ?? UIImage()
        if let data = image.pngData() {
            // 保存用户数据
            userInfo = UserInfo(userName: userName.text ?? initUserName , userIntro: userInfoName.text ?? initUserIntro, userImageData: data)
        }
        saveUserInfoData()
    }
    
    // 隐藏键盘
    @objc func hideKeyboard() {
        // 取消 textField 的第一响应者状态，即隐藏键盘
        userName.resignFirstResponder()
        userInfoName.resignFirstResponder()
    }
}

extension UserVC: UITextFieldDelegate {
    // 当用户按下 Return 键时调用
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 取消 textField 的第一响应者状态，即结束编辑
        if textField.text == "" {
            textField.text = textField.placeholder
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveData()
    }
}

extension UserVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 选择照片
    @objc func changeImageHandle(sender: UITapGestureRecognizer) {
        ButtonAnimate(sender.view ?? UIView())
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            userImageView.image = image
        }
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.saveData()
        }
    }
}
