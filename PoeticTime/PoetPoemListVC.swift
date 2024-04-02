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
        poemListCollectionView.backgroundColor = "#7EB5B1".pt_argbColor
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
    }
    
    // 配制UI
    func setPoemListViewUI() {
        view.backgroundColor = "#7EB5B1".pt_argbColor
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
}
