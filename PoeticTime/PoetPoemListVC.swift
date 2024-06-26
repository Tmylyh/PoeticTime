//
//  PoetPoemListVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/2.
//

import UIKit
import SnapKit

class PoetPoemListVC: UIViewController {
    
    // 诗人id
    var poetId = ""
    
    // 诗人名
    var poetName = ""
    
    // 该诗人的所有诗
    var poemsWithPoetData: [Poem] = []
    
    // 诗人Label
    lazy var poetLabel: UILabel = {
        let poetLabel = UILabel()
        poetLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 24)
        poetLabel.text = poetName
        poetLabel.textAlignment = .center
        poetLabel.textColor = .black
        return poetLabel
    }()
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "poetic_time_back_image"), for: .normal)
        backButton.addTarget(self, action: #selector(dismissCurrentVC), for: .touchUpInside)
        return backButton
    }()
    
    // 诗词的列表
    lazy var poemListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let poemListCollectionView = UICollectionView(frame: CGRect(x: 0, y: 88, width: view.bounds.width, height: Bounds.height - 88), collectionViewLayout: layout)
        poemListCollectionView.backgroundColor = colorData["DynastyVC_poetTextView_\(currentDynasty.rawValue)_color1"]?.pt_argbColor
        poemListCollectionView.isHidden = true
        poemListCollectionView.delegate = self
        poemListCollectionView.dataSource = self
        poemListCollectionView.contentInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        poemListCollectionView.showsVerticalScrollIndicator = false
        poemListCollectionView.register(PtPoemCell.self, forCellWithReuseIdentifier: kPtPoemCell)
        poemListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return poemListCollectionView
    }()
    
    init(poetId: String) {
        super.init(nibName: nil, bundle: nil)
        self.poetId = poetId
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPoemListViewUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else {
                debugPrint("poemListCollectionView被隐藏了")
                return
            }
            moveAnimationWithCollectionView(collectionView: self.poemListCollectionView, translationY: 900)
            self.poemListCollectionView.isHidden = false
        }
    }
    
    
    
    // 配制UI
    func setPoemListViewUI() {
        view.backgroundColor = colorData["DynastyVC_poetTextView_\(currentDynasty.rawValue)_color1"]?.pt_argbColor
        view.addSubview(backButton)
        view.addSubview(poetLabel)
        view.addSubview(poemListCollectionView)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(44)
            make.width.height.equalTo(32)
        }
        
        poetLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarHeight)
        }
        
        poemListCollectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(poetLabel.snp.bottom).offset(8)
        }
    }
    
    // dimiss当前View
    @objc func dismissCurrentVC() {
        hero.dismissViewController()
    }
}

extension PoetPoemListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return poemsWithPoetData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPtPoemCell, for: indexPath) as! PtPoemCell
        cell.backgroundColor = .white
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        cell.poemId = poemsWithPoetData[indexPath.row].poemId
        cell.changeStarStatusCompletion = { [weak self] isStar in
            guard let self = self else { return }
            self.poemsWithPoetData[indexPath.row] = Poem(poemId: self.poemsWithPoetData[indexPath.row].poemId, poemName: self.poemsWithPoetData[indexPath.row].poemName, poetId: self.poemsWithPoetData[indexPath.row].poetId, dynastyId: self.poemsWithPoetData[indexPath.row].dynastyId, poemBody: self.poemsWithPoetData[indexPath.row].poemBody, poemStar: isStar)
        }
        var tmpText = ""
        // 字数少就纵向排
        if poemsWithPoetData[indexPath.row].poemName.count <= 3 {
            tmpText = verticalText(text: poemsWithPoetData[indexPath.row].poemName)
        } else {
            tmpText = poemsWithPoetData[indexPath.row].poemName
        }
        cell.poemText = tmpText
        cell.poetText = verticalText(text: poetName)
        cell.contentView.hero.id = "poemCell\(indexPath.row)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - 48) / 3 // 设置每行3个item，左右间距各是8
        let cellHeight = cellWidth // 控制 cell 的高宽比
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let cell = collectionView.cellForItem(at: indexPath) as? PtPoemCell else { return }
        ButtonAnimate(cell)
        let poemDetailVC = PoemDetailVC()
        poemDetailVC.poemId = poemsWithPoetData[indexPath.row].poemId
        poemDetailVC.poemName = poemsWithPoetData[indexPath.row].poemName
        poemDetailVC.poemBody = poemsWithPoetData[indexPath.row].poemBody
        poemDetailVC.isStar = poemsWithPoetData[indexPath.row].poemStar
        poemDetailVC.poetId = poetId
        poemDetailVC.dynastyId = poemsWithPoetData[indexPath.row].dynastyId
        poemDetailVC.changeStarStatus = { [weak self] isStar in
            guard let self = self else { return }
            self.poemsWithPoetData[indexPath.row] = Poem(poemId: self.poemsWithPoetData[indexPath.row].poemId, poemName: self.poemsWithPoetData[indexPath.row].poemName, poetId: self.poemsWithPoetData[indexPath.row].poetId, dynastyId: self.poemsWithPoetData[indexPath.row].dynastyId, poemBody: self.poemsWithPoetData[indexPath.row].poemBody, poemStar: isStar)
            let star = isStar ? "is" : "no"
            // 修改UI
            cell.starButton.setImage(UIImage(named: "poetic_time_poem_card_\(star)_star_image"), for: .normal)
        }
        let poet = poetData.filter { $0.poetId == poemsWithPoetData[indexPath.row].poetId }
        let dynasty = dynastyData.filter { $0.dynastyId == poemsWithPoetData[indexPath.row].dynastyId }
        poemDetailVC.poetName = poet.first?.poetName ?? ""
        poemDetailVC.dynastyName = dynasty.first?.dynastyName ?? ""
        let uuid = "\(UUID())"
        cell.hero.id = uuid
        poemDetailVC.view.hero.id = uuid
        poemDetailVC.hero.isEnabled = true
        poemDetailVC.modalPresentationStyle = .overFullScreen
        present(poemDetailVC, animated: true)
    }
}
