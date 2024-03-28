//
//  DynastyVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/28.
//

import UIKit
import DBSphereTagCloudSwift
import SnapKit

class DynastyVC: UIViewController {
    
    // 3D球的半径
    let sphereRaius = 120
    
    // animationView的字体
    let animationFont = "yuweij"
    
    // infoView的子视图集合
    var infoSubViews: [UIView] = []
    
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
    
    // 中转动画
    lazy var animationView: BezierText = {
        let width = self.view.frame.height - 150
        let height = self.view.frame.width
        let text = BezierText(frame: CGRect(x: -(width - height) / 2, y: 0 , width: width, height: self.view.frame.height))
        text.dismissAnimationBlock = dismissAnimationHandle
        text.backgroundColor = .clear
        text.show(text: "长太息以掩涕兮，哀民生之多艰。长太息以掩涕兮，哀民生之多艰。哀民生之多艰。长太息以掩涕兮，哀民生之多艰。哀民生之多艰。长太息以掩涕兮，哀民生之多艰。长太息以掩涕兮，哀民生之多艰。长太息以掩涕兮，哀民生之多艰。哀民生之多艰。长太息以掩涕兮，哀民生之多艰。哀民生之多艰。长太息以掩涕兮，哀民生之多艰。长太息以掩涕兮，哀民生之多艰。哀民生之多艰。长太息以掩涕兮，哀民生之多艰。哀民生之多艰。长太息以掩涕兮，哀民生之多艰。")
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
        animationBackgroundView.backgroundColor = .white
        animationBackgroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAnimationHandle))
        animationBackgroundView.addGestureRecognizer(tap)
        return animationBackgroundView
    }()
    
    // 诗人球体
    var sphereView: DBSphereView!
    
    // 朝代背景
    lazy var dynastyStoryButton: UIButton = {
        let dynastyStoryButton = UIButton()
        dynastyStoryButton.backgroundColor = .red
        dynastyStoryButton.setTitle("朝代背景", for: .normal)
        dynastyStoryButton.setTitle("选中背景", for: .selected)
        dynastyStoryButton.isSelected = true
        dynastyStoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        dynastyStoryButton.setTitleColor(.black, for: .normal)
        dynastyStoryButton.tag = 0
//        dynastyStoryButton.layer.cornerRadius = 20
        dynastyStoryButton.addTarget(self, action: #selector(changeInfoView), for: .touchUpInside)
        return dynastyStoryButton
    }()
    
    // 个人作诗
    lazy var diyPoemButton: UIButton = {
        let diyPoemButton = UIButton()
        diyPoemButton.backgroundColor = .blue
        diyPoemButton.setTitle("个人作诗", for: .normal)
        diyPoemButton.setTitle("选中作诗", for: .selected)
        diyPoemButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        diyPoemButton.setTitleColor(.black, for: .normal)
        diyPoemButton.tag = 1
//        diyPoemButton.layer.cornerRadius = 20
        diyPoemButton.addTarget(self, action: #selector(changeInfoView), for: .touchUpInside)
        return diyPoemButton
    }()
    
    // 诗词列表
    lazy var poemListButton: UIButton = {
        let poemListButton = UIButton()
        poemListButton.backgroundColor = .yellow
        poemListButton.setTitle("诗词列表", for: .normal)
        poemListButton.setTitle("选中列表", for: .selected)
        poemListButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        poemListButton.setTitleColor(.black, for: .normal)
        poemListButton.tag = 2
//        poemListButton.layer.cornerRadius = 20
        poemListButton.addTarget(self, action: #selector(changeInfoView), for: .touchUpInside)
        return poemListButton
    }()
    
    // infoView的页面切换控制器
    private lazy var stackButtonView: UIStackView = {
        let stackButtonView = UIStackView()
        stackButtonView.axis = .horizontal
//        stackButtonView.spacing = 8
        stackButtonView.addArrangedSubview(dynastyStoryButton)
        stackButtonView.addArrangedSubview(diyPoemButton)
        stackButtonView.addArrangedSubview(poemListButton)
        return stackButtonView
    }()
    
    // 朝代背景、作诗、诗词列表所在的View
    lazy var infoScrollView: UIScrollView = {
        let infoScrollView = UIScrollView(frame: CGRect(x: 0, y: sphereRaius * 2 + statusBarHeight + 32, width: Int(Bounds.width), height: 800))
        // 使用页面控制器
        infoScrollView.isPagingEnabled = true
        // 禁止边界弹性滚动
        infoScrollView.bounces = false
        // 设置滚动视图范围
        infoScrollView.contentSize = CGSize(width: Bounds.width * 3, height: infoScrollView.frame.height)
        // 禁止滚动视图的滚动条
        infoScrollView.showsHorizontalScrollIndicator = false
        infoScrollView.showsVerticalScrollIndicator = false
        
        infoScrollView.delegate = self
        return infoScrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        sphereView = DBSphereView(frame: CGRect(x: Int(Bounds.width) / 2 - sphereRaius, y: statusBarHeight + 8, width: sphereRaius * 2, height: sphereRaius * 2))
        setSphereUI()
        setUIAndLayout()
        setInfoSubViewUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setAnimationUI()
    }
    
    // dismiss掉动画View
    @objc func dismissAnimationHandle() {
        animationBackgroundView.removeFromSuperview()
        animationView.removeFromSuperview()
    }
    
    @objc func finishAnimationHandle() {
        // 点击按钮时取消动画
        // 移除 "strokeEnd" 键值的动画
        animationView.pathLayer.removeAnimation(forKey: "strokeEnd")
    }
    
    // 控制器切换页面操作
    @objc func changeInfoView(_ sender: UIButton) {
        let index = sender.tag
        self.currentPage = index
    }
    
    // 配制中转动画
    func setAnimationUI() {
        animationView.transform = CGAffineTransform(rotationAngle: .pi / 2)
        self.view.addSubview(animationView)
    }
    
    // 配制页面UI和布局
    func setUIAndLayout() {
        self.view.addSubview(sphereView)
        self.view.addSubview(stackButtonView)
        self.view.addSubview(infoScrollView)
        self.view.addSubview(animationBackgroundView)
        
        diyPoemButton.snp.makeConstraints { (make) in
            make.width.equalTo(dynastyStoryButton)
        }
    
        poemListButton.snp.makeConstraints { (make) in
            make.width.equalTo(dynastyStoryButton)
        }
        
        stackButtonView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(sphereRaius * 2 + statusBarHeight + 32)
            make.height.equalTo(44)
            make.width.equalTo(250)
        }
        
        infoScrollView.snp.makeConstraints { make in
            make.top.equalTo(stackButtonView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        animationBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // 配制info的子View
    func setInfoSubViewUI() {
        let view1 = UIView(frame: viewInitRect)
        view1.backgroundColor = .red
        let view2 = UIView(frame: viewInitRect)
        view2.backgroundColor = .blue
        let view3 = UIView(frame: viewInitRect)
        view3.backgroundColor = .yellow
        infoSubViews.append(view1)
        infoSubViews.append(view2)
        infoSubViews.append(view3)
        for (index, view) in infoSubViews.enumerated() {
            view.frame = CGRect(x: index * Int(Bounds.width), y: 0, width: Int(Bounds.width), height: Int(infoScrollView.frame.height))
            infoScrollView.addSubview(view)
        }
    }
    
    // 配制球体UI
    func setSphereUI() {
        var array = [UIButton]()
        for i in 1..<40 {
            let btn = UIButton(type: UIButton.ButtonType.system)
            btn.setTitle("李白\(i)", for: .normal)
            btn.setTitleColor(.darkGray, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.light)
            btn.frame = CGRect(x: 0, y: 0, width: 100, height: 24)
            btn.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
            array.append(btn)
            sphereView.addSubview(btn)
        }
        sphereView.setCloudTags(array)
        sphereView.backgroundColor = .clear
    }
    
    // pageControl点击后的联动
    func pageControlValueChanged() {
        let targetOffsetX = CGFloat(self.currentPage) * Bounds.width
        infoScrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
        guard let viewWithTag = self.view.viewWithTag(currentPage) as? UIButton else { return }
        clearSelected()
        viewWithTag.isSelected = true
    }
    
    func clearSelected() {
        dynastyStoryButton.isSelected = false
        diyPoemButton.isSelected = false
        poemListButton.isSelected = false
    }
    
    @objc func buttonTapped() {
        print(123)
    }
}


extension DynastyVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentPage = Int(scrollView.contentOffset.x / Bounds.width)
    }
    
}
