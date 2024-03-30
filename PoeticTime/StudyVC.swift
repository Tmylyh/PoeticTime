//
//  StudyVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/20.
//

import UIKit
import SnapKit
import Hero

class StudyVC: UIViewController {
    
    // 朝代文本
    public var dynastyStartTime = ""
    public var dynastyEndTime = ""
    public var dynastyName = ""
    
    // 朝代诗风描述
    public var dynastyDescription = ""
    
    // 朝代label
    private lazy var dynastyLabel: UILabel = {
        let dynastyLabel = UILabel()
        dynastyLabel.text = "[公元\(dynastyStartTime)-\(dynastyEndTime)年] \(dynastyName)"
        dynastyLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 32)
        dynastyLabel.textColor = "#27827C".pt_argbColor
        return dynastyLabel
    }()
    
    // 朝代诗风描述
    private lazy var dynastyDescriptionLabel: UILabel = {
        let dynastyDescriptionLabel = UILabel()
        dynastyDescriptionLabel.text = dynastyDescription
        dynastyDescriptionLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 22)
        dynastyDescriptionLabel.textColor = "#175450".pt_argbColor
        return dynastyDescriptionLabel
    }()
    
    private lazy var dynastyDescriptionBackground: UIView = {
        let dynastyDescriptionBackground = UIView(frame: viewInitRect)
        dynastyDescriptionBackground.backgroundColor = "#A7C4C2".pt_argbColor
        return dynastyDescriptionBackground
    }()
    
    // 第一个偏移的index
    let firstOffsetIndex = 0
    
    // 背景
    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(frame: viewInitRect)
        backgroundImageView.image = UIImage(named: "poetic_time_study_background")
        backgroundImageView.contentMode = .scaleAspectFit
        return backgroundImageView
    }()
    
    private lazy var layout: PtCardDetailLayout = {
        let layout = PtCardDetailLayout()
        layout.firstOffsetIndex = firstOffsetIndex
        layout.activeIndexPathDidChangeBlock = { [weak self] index in
            guard let self = self else { return }
            self.updateDynastyCell(index: index)
        }
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 800, height: 400), collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PtCardCollectionViewCell.self, forCellWithReuseIdentifier: kPtCardCollectionViewCell)
        return collectionView
    }()
    
    // 分隔线
    private lazy var separateLeftLine: UIView = {
        let separateLeftLine = UIView(frame: viewInitRect)
        separateLeftLine.backgroundColor = "#72A3A0".pt_argbColor
        return separateLeftLine
    }()
    
    private lazy var separateCircle: UIView = {
        let separateCircle = UIView(frame: viewInitRect)
        return separateCircle
    }()
    
    private lazy var separateRightLine: UIView = {
        let separateRightLine = UIView(frame: viewInitRect)
        separateRightLine.backgroundColor = "#72A3A0".pt_argbColor
        return separateRightLine
    }()
    
    private lazy var dynastyLayout: PtDynastyLayout = {
        let dynastyLayout = PtDynastyLayout()
        return dynastyLayout
    }()
    
    // 朝代collectionView
    private lazy var dynastyCollectionView: UICollectionView = {
        let dynastyCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: Bounds.width, height: 100), collectionViewLayout: dynastyLayout)
        dynastyCollectionView.backgroundColor = .clear
        dynastyCollectionView.delegate = self
        dynastyCollectionView.dataSource = self
        dynastyCollectionView.showsVerticalScrollIndicator = false
        dynastyCollectionView.showsHorizontalScrollIndicator = false
        dynastyCollectionView.register(PtDynastyCollectionViewCell.self, forCellWithReuseIdentifier: kPtDynastyCollectionViewCell)
        return dynastyCollectionView
    }()
    
    // 上一个活跃的cell的IndexPath
    private var preIndex = IndexPath(row: 0, section: 0)
    
    private func updateDynastyCell(index: IndexPath) {
        guard let cell = dynastyCollectionView.cellForItem(at: index) as? PtDynastyCollectionViewCell else { return }
        // 更新上方Label信息
        updateDynastyLabel(index: index.row)
        // 更新颜色
        cell.changeActiveColor()
        cell.bigFactor()
        guard let preCell = dynastyCollectionView.cellForItem(at: preIndex) as? PtDynastyCollectionViewCell else { return }
        preCell.resetColor()
        preIndex = index
    }

    // 配制布局UI
    private func setUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(collectionView)
        view.addSubview(dynastyLabel)
        view.addSubview(dynastyDescriptionBackground)
        view.addSubview(dynastyDescriptionLabel)
        view.addSubview(separateLeftLine)
        view.addSubview(separateCircle)
        view.addSubview(separateRightLine)
        view.addSubview(dynastyCollectionView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(163)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-ptTabBarHeight - 104)
        }
        
        dynastyLabel.snp.makeConstraints { make in
            make.top.equalTo(78)
            make.centerX.equalToSuperview()
            make.height.equalTo(34)
        }
        
        dynastyDescriptionBackground.snp.makeConstraints { make in
            make.top.equalTo(dynastyLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
            make.width.equalTo(240)
        }
        
        dynastyDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(dynastyLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        separateLeftLine.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalTo(Bounds.width / 2 - 24)
            make.height.equalTo(5)
        }
        
        separateCircle.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        separateRightLine.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.right.equalToSuperview()
            make.width.equalTo(Bounds.width / 2 - 24)
            make.height.equalTo(5)
        }
        
        dynastyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(separateCircle.snp.bottom)
            make.right.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-ptTabBarHeight)
        }
    }
    
    // 绘制圆
    private func setCircle() {
        // 获取 separateCircle 的中心点坐标
        let centerX = separateCircle.center.x - 42
        let centerY = separateCircle.center.y - 46
        // 设置圆的半径
        let radius: CGFloat = 10

        // 创建圆形路径
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)// clockwise顺时针绘制

        // 创建 CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath

        // 设置填充颜色和边框颜色
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = "#72A3A0".pt_argbColor?.cgColor
        shapeLayer.lineWidth = 2

        // 将 CAShapeLayer 添加到 separateCircle 的 layer 上
        separateCircle.layer.addSublayer(shapeLayer)
    }
    
    // 刷新文本
    private func updateDynastyLabel(index: Int) {
        self.dynastyStartTime = dynastyStartTimeData[index]
        self.dynastyEndTime = dynastyEndTimeData[index]
        self.dynastyName = dynastyNameData[index]
        self.dynastyDescription = dynastyDescriptionData[index]
        // 更新 dynastyLabel 的文本内容
        self.dynastyLabel.text = "[公元\(self.dynastyStartTime)-\(self.dynastyEndTime)年] \(self.dynastyName)"
        self.dynastyDescriptionLabel.text = dynastyDescription
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setCircle()
    }
}

extension StudyVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9  // section数量是一个较大的值，用来模拟无限循环效果
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPtCardCollectionViewCell, for: indexPath) as? PtCardCollectionViewCell else { return UICollectionViewCell() }
            cell.contentImageView.image = UIImage(named: dynastyCardImage[indexPath.row])
            return cell
        } else if collectionView == self.dynastyCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPtDynastyCollectionViewCell, for: indexPath) as? PtDynastyCollectionViewCell else { return UICollectionViewCell() }
            cell.dynastyText = dynastyNameData[indexPath.row]
            if indexPath.row == collectionView.numberOfItems(inSection: 0) / 2 {
                updateDynastyLabel(index: indexPath.row)
                cell.changeActiveColor()
                cell.bigFactor()
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard layout.activeIndexPath == indexPath else {
            // 如果当前点击的cell不是活跃的cell则需要移动到被点击的cell上
            let point = layout.contentOffset(for: indexPath)
            self.collectionView.setContentOffset(point, animated: true)
            layout.activeIndexPath = indexPath
            guard let cell = self.dynastyCollectionView.cellForItem(at: indexPath) as? PtDynastyCollectionViewCell else { return }
            cell.changeActiveColor()
            cell.bigFactor()
            return
        }
        if collectionView == self.collectionView {
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? PtCardCollectionViewCell else { return }
            let dynastyVC = DynastyVC()
            cell.hero.id = "StudyVC2DynastyVC\(indexPath.row)"
            dynastyVC.hero.isEnabled = true
            dynastyVC.view.hero.id = "StudyVC2DynastyVC\(indexPath.row)"
            dynastyVC.modalPresentationStyle = .fullScreen
            dynastyVC.dynastyStoryData = dynastyData[indexPath.row]
            // 查询当朝诗人
            let poetsWithDynasty = poetData.filter { $0.dynastyId == dynastyVC.dynastyStoryData.dynastyId }
            dynastyVC.poetWithDynastyData = poetsWithDynasty
            present(dynastyVC, animated: true)
        }
    }
}
