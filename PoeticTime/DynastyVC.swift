//
//  DynastyVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/28.
//

import UIKit
import DBSphereTagCloudSwift
import SnapKit
import Hero

class DynastyVC: UIViewController {
    
    // 3D球的半径
    let sphereRaius = 120
    
    // animationView的字体
    let animationFont = ZiTi.yuweij
    
    // infoView的子视图集合
    var infoSubViews: [UIView] = []
    
    // 当前页面
    var _currentPage: Int = 0
    
    // 诗人字典
    var tagWithPoet: [Int: String] = [:]
    
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
    
    // 朝代故事的数据
    var dynastyStoryData: Dynasty = Dynasty(dynastyId: "", dynastyName: "", dynastyInfo: "")
    
    // 当朝诗人数据
    var poetWithDynastyData: [Poet] = []
    
    // 当朝诗词诗句
    var poemWithDynastyData: [Poem] = []
    
    // 当朝个人作诗数据
    var userPoemCurrentData: [UserPoem] = []
    
    // 跳转动画文本
    var animationText: String = ""
    
    // 中转动画
    lazy var animationView: BezierText = {
        let width = self.view.frame.height - 150
        let height = self.view.frame.width
        let text = BezierText(frame: CGRect(x: -44, y: -44, width: width, height: self.view.frame.height))
        text.dismissAnimationBlock = dismissAnimationHandle
        text.backgroundColor = .clear
        text.show(text: animationText)
        text.isUserInteractionEnabled = true
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(finishAnimationHandle))
        // 双击手势
        doubleTapGesture.numberOfTapsRequired = 2
        text.addGestureRecognizer(doubleTapGesture)
        return text
    }()
    
    // 动画手写字体的背景
    lazy var animationBackgroundView: UIImageView = {
        let animationBackgroundView = UIImageView(frame: viewInitRect)
        animationBackgroundView.image = UIImage(named: "poetic_time_dynasty_animation_background_image")
        animationBackgroundView.backgroundColor = "#D8F0EC".pt_argbColor
        animationBackgroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAnimationHandle))
        animationBackgroundView.addGestureRecognizer(tap)
        return animationBackgroundView
    }()
    
    // 诗人球体
    var sphereView: DBSphereView!
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "poetic_time_dynasty_back_image"), for: .normal)
        backButton.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(dismissCurrentVC), for: .touchUpInside)
        return backButton
    }()
    
    // 朝代标签
    lazy var tagLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.text = "\(dynastyStoryData.dynastyName.prefix(1))\n\(dynastyStoryData.dynastyName.suffix(1))"
        tagLabel.textColor = .white
        tagLabel.numberOfLines = 0
        tagLabel.textAlignment = .center
        tagLabel.font = UIFont(name: ZiTi.yuweij.rawValue, size: 62)
        return tagLabel
    }()
    
    // stackView的分割线
    lazy var seperateStackLine1: UIView = {
        let seperateStackLine = UIView(frame: viewInitRect)
        seperateStackLine.backgroundColor = "#F5FCFB".pt_argbColor
        seperateStackLine.layer.cornerRadius = 10
        return seperateStackLine
    }()
    
    lazy var seperateStackLine2: UIView = {
        let seperateStackLine = UIView(frame: viewInitRect)
        seperateStackLine.backgroundColor = "#F5FCFB".pt_argbColor
        seperateStackLine.layer.cornerRadius = 10
        return seperateStackLine
    }()
    
    // 朝代背景
    lazy var dynastyStoryButton: UIButton = {
        let dynastyStoryButton = UIButton()
        dynastyStoryButton.backgroundColor = "#7EB5B1".pt_argbColor
        dynastyStoryButton.setTitle("诗史纪元", for: .normal)
        dynastyStoryButton.isSelected = true
        dynastyStoryButton.titleLabel?.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 20)
        dynastyStoryButton.setTitleColor(.black, for: .normal)
        dynastyStoryButton.tag = 1
        dynastyStoryButton.addTarget(self, action: #selector(changeInfoView), for: .touchUpInside)
        return dynastyStoryButton
    }()
    
    // 个人作诗
    lazy var diyPoemButton: UIButton = {
        let diyPoemButton = UIButton()
        diyPoemButton.backgroundColor = "#7EB5B1".pt_argbColor
        diyPoemButton.setTitle("笔下生花", for: .normal)
        diyPoemButton.titleLabel?.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 20)
        diyPoemButton.setTitleColor(.white, for: .normal)
        diyPoemButton.tag = 2
        diyPoemButton.addTarget(self, action: #selector(changeInfoView), for: .touchUpInside)
        return diyPoemButton
    }()
    
    // 诗词列表
    lazy var poemListButton: UIButton = {
        let poemListButton = UIButton()
        poemListButton.backgroundColor = "#7EB5B1".pt_argbColor
        poemListButton.setTitle("华章荟萃", for: .normal)
        poemListButton.titleLabel?.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 20)
        poemListButton.setTitleColor(.white, for: .normal)
        poemListButton.tag = 3
        poemListButton.addTarget(self, action: #selector(changeInfoView), for: .touchUpInside)
        return poemListButton
    }()
    
    // infoView的页面切换控制器
    lazy var stackButtonView: UIStackView = {
        let stackButtonView = UIStackView()
        stackButtonView.backgroundColor = "7EB5B1".pt_argbColor
        stackButtonView.axis = .horizontal
        stackButtonView.spacing = 2
        stackButtonView.addArrangedSubview(dynastyStoryButton)
        stackButtonView.addArrangedSubview(diyPoemButton)
        stackButtonView.addArrangedSubview(poemListButton)
        return stackButtonView
    }()
    
    // 朝代背景的翻页控制器
    var pageControl: UIPageControl?
    
    // 朝代背景、作诗、诗词列表所在的View
    lazy var infoScrollView: UIScrollView = {
        let infoScrollViewY = sphereRaius * 2 + statusBarHeight + 32
        let infoScrollView = UIScrollView(frame: CGRect(x: 0, y: infoScrollViewY, width: Int(Bounds.width), height: Int(Bounds.height) - infoScrollViewY - statusBarHeight))
        
        // 使用页面控制器
        infoScrollView.isPagingEnabled = true
        // 禁止边界弹性滚动
        infoScrollView.bounces = false
        // 设置滚动视图范围
        infoScrollView.contentSize = CGSize(width: Bounds.width * 3, height: 0)
        // 禁止滚动视图的滚动条
        infoScrollView.showsHorizontalScrollIndicator = false
        infoScrollView.showsVerticalScrollIndicator = false
        infoScrollView.delegate = self
        return infoScrollView
    }()
    
    // 诗史纪元
    lazy var dynastyStoryView: UIImageView = {
        let dynastyStoryView = UIImageView(frame: viewInitRect)
        dynastyStoryView.image = UIImage(named: "poetic_time_dynasty_story_image")
        dynastyStoryView.contentMode = .scaleAspectFill
        return dynastyStoryView
    }()
    
    // 装字的ScrollView
    lazy var dynastyStoryContentView: UIScrollView = {
        let dynastyStoryContentView = UIScrollView(frame: viewInitRect)
        // 使用页面控制器
        dynastyStoryContentView.isPagingEnabled = true
        // 禁止边界弹性滚动
        dynastyStoryContentView.bounces = false
        // 设置滚动视图范围
        dynastyStoryContentView.contentSize = CGSize(width: Bounds.width * 3, height: 0)
        // 禁止滚动视图的滚动条
        dynastyStoryContentView.showsHorizontalScrollIndicator = false
        dynastyStoryContentView.showsVerticalScrollIndicator = false
        
        dynastyStoryContentView.delegate = self
        dynastyStoryContentView.layer.cornerRadius = 20
        dynastyStoryContentView.backgroundColor = "#CCCCCC".pt_argbColor
        dynastyStoryContentView.layer.masksToBounds = true
        dynastyStoryContentView.layer.opacity = 0.8
        return dynastyStoryContentView
    }()
    
    // 装字的View， 这里复用性不高，因为只能有不超过四页的内容，多了就不行，这里只放了4个label
    lazy var dynastyStoryLabel1: UILabel = {
        let dynastyStoryLabel1 = UILabel(frame: viewInitRect)
        dynastyStoryLabel1.layer.cornerRadius = 20
        dynastyStoryLabel1.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 22)
        dynastyStoryLabel1.backgroundColor = "#CCCCCC".pt_argbColor
        dynastyStoryLabel1.layer.masksToBounds = true
        dynastyStoryLabel1.numberOfLines = 0
        dynastyStoryLabel1.layer.opacity = 0.8
        return dynastyStoryLabel1
    }()
    
    lazy var dynastyStoryLabel2: UILabel = {
        let dynastyStoryLabel2 = UILabel(frame: viewInitRect)
        dynastyStoryLabel2.layer.cornerRadius = 20
        dynastyStoryLabel2.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 22)
        dynastyStoryLabel2.backgroundColor = "#CCCCCC".pt_argbColor
        dynastyStoryLabel2.layer.masksToBounds = true
        dynastyStoryLabel2.numberOfLines = 0
        dynastyStoryLabel2.layer.opacity = 0.8
        return dynastyStoryLabel2
    }()
    
    lazy var dynastyStoryLabel3: UILabel = {
        let dynastyStoryLabel3 = UILabel(frame: viewInitRect)
        dynastyStoryLabel3.layer.cornerRadius = 20
        dynastyStoryLabel3.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 22)
        dynastyStoryLabel3.backgroundColor = "#CCCCCC".pt_argbColor
        dynastyStoryLabel3.layer.masksToBounds = true
        dynastyStoryLabel3.numberOfLines = 0
        dynastyStoryLabel3.layer.opacity = 0.8
        return dynastyStoryLabel3
    }()
    
    lazy var dynastyStoryLabel4: UILabel = {
        let dynastyStoryLabel4 = UILabel(frame: viewInitRect)
        dynastyStoryLabel4.layer.cornerRadius = 20
        dynastyStoryLabel4.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 22)
        dynastyStoryLabel4.backgroundColor = "#CCCCCC".pt_argbColor
        dynastyStoryLabel4.layer.masksToBounds = true
        dynastyStoryLabel4.numberOfLines = 0
        dynastyStoryLabel4.layer.opacity = 0.8
        return dynastyStoryLabel4
    }()
    
    // 笔下生花
    lazy var poemUserTableView: UITableView = {
        let poemUserTableView = UITableView(frame: CGRect(x: 0, y: 88, width: view.bounds.width, height: Bounds.height - 80))
        poemUserTableView.backgroundColor = "#7EB5B1".pt_argbColor
        // 去掉cell 之间的横线
        poemUserTableView.separatorStyle = .none
        poemUserTableView.showsVerticalScrollIndicator = false
        poemUserTableView.showsHorizontalScrollIndicator = false
        poemUserTableView.delegate = self
        poemUserTableView.dataSource = self
        poemUserTableView.register(DynastyUserPoemCell.self, forCellReuseIdentifier: kDynastyUserPoemCell)
        return poemUserTableView
    }()
    
    // 作诗按钮
    lazy var poemWriteButton: UIButton = {
        let poemWriteButton = UIButton()
        poemWriteButton.addTarget(self, action: #selector(wirteButtonHandle), for: .touchUpInside)
        poemWriteButton.titleLabel?.font = .systemFont(ofSize: 16)
        poemWriteButton.backgroundColor = .white
        poemWriteButton.isHidden = true
        poemWriteButton.layer.cornerRadius = 20
        return poemWriteButton
    }()
    
    // 作诗按钮背景图
    lazy var poemWriteBackGroundImage: UIImageView = {
        let poemWriteBackGroundImage = UIImageView(frame: viewInitRect)
        poemWriteBackGroundImage.image = UIImage(named: "poetic_time_dynasty_write_button_background_image")
        poemWriteBackGroundImage.contentMode = .scaleAspectFit
        poemWriteBackGroundImage.isHidden = true
        return poemWriteBackGroundImage
    }()
    
    // 作诗按钮文本
    lazy var poemWriteLabel: UILabel = {
        let poemWriteLabel = UILabel(frame: viewInitRect)
        poemWriteLabel.text = "留诗此朝"
        poemWriteLabel.textColor = .black
        poemWriteLabel.textAlignment = .center
        poemWriteLabel.isHidden = true
        poemWriteLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 20)
        poemWriteLabel.backgroundColor = .clear
        return poemWriteLabel
    }()
    
    // 华章荟萃
    lazy var poemListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let poemListCollectionView = UICollectionView(frame: CGRect(x: 0, y: 88, width: view.bounds.width, height: Bounds.height - 88), collectionViewLayout: layout)
        poemListCollectionView.backgroundColor = "#7EB5B1".pt_argbColor
        poemListCollectionView.delegate = self
        poemListCollectionView.dataSource = self
        poemListCollectionView.contentInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        poemListCollectionView.showsVerticalScrollIndicator = false
        poemListCollectionView.register(PtPoemCell.self, forCellWithReuseIdentifier: kPtPoemCell)
        poemListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return poemListCollectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = "#0E3036".pt_argbColor
        sphereView = DBSphereView(frame: CGRect(x: Int(Bounds.width) / 2 - sphereRaius, y: statusBarHeight + 8, width: sphereRaius * 2, height: sphereRaius * 2))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUIAndLayout()
        setInfoSubViewUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setAnimationUI()
    }
    
    // 状态栏颜色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // 或者 .default，取决于你想要的状态栏颜色
    }
    
    // dimiss当前View
    @objc func dismissCurrentVC() {
        hero.dismissViewController()
    }
    
    // dismiss掉动画View
    @objc func dismissAnimationHandle() {
        animationBackgroundView.removeFromSuperview()
        animationView.removeFromSuperview()
        // 动画页面关闭再播放球动画
        setSphereUI()
        self.view.addSubview(sphereView)
    }
    
    @objc func finishAnimationHandle() {
        // 点击按钮时取消动画
        // 移除 "strokeEnd" 键值的动画
        animationView.pathLayer.removeAnimation(forKey: "strokeEnd")
    }
    
    // 配制中转动画
    func setAnimationUI() {
        animationView.transform = CGAffineTransform(rotationAngle: .pi / 2)
        self.view.addSubview(animationView)
    }
    
    // 作诗按钮
    @objc func wirteButtonHandle(sender: UIButton) {
        ButtonAnimate(sender)
        ButtonAnimate(poemWriteBackGroundImage)
        ButtonAnimate(poemWriteLabel)
        
        let writePoemVC = PtWritePoemVC()
        sender.hero.id = "writePoem"
        writePoemVC.isFromInsert = true
        let image = UIImage(named: "poetic_time_write_poem_image") ?? UIImage()
        if let data = image.pngData() {
            writePoemVC.userPoemImageData = data
        }
        writePoemVC.userPoemDynasty = dynastyStoryData.dynastyName
        writePoemVC.reloadTableView = tableViewDataReload
        writePoemVC.view.hero.id = "writePoem"
        writePoemVC.hero.isEnabled = true
        writePoemVC.heroModalAnimationType = .zoom
        writePoemVC.modalPresentationStyle = .overFullScreen
        present(writePoemVC, animated: true)
    }
    
    // 重新加载数据
    func tableViewDataReload() {
        userPoemCurrentData = userPoemData.filter {
            $0.userPoemDynasty == dynastyStoryData.dynastyName
        }
        poemUserTableView.reloadData()
    }
}
