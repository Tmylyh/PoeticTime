//
//  PtPoemCell.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/30.
//

import UIKit
import SnapKit

class PtPoemCell: UICollectionViewCell {
    
    // 诗词id
    var _poemId: String = ""
    
    var poemId: String {
        get {
            return "不可见"
        }
        set {
            let poem = poemData.filter { $0.poemId == newValue }
            let isStar = poem.first?.poemStar ?? false ? "is" : "no"
            starButton.setImage(UIImage(named: "poetic_time_poem_card_\(isStar)_star_image"), for: .normal)
            _poemId = newValue
        }
    }
    
    // 诗词名
    var poemText: String {
        get {
            return "不可见"
        }
        set {
            poemLabel.text = newValue
        }
    }
    
    // 诗人名
    var poetText: String {
        get {
            return "不可见"
        }
        set {
            poetLabel.text = newValue
        }
    }
    
    // 诗人logo
    lazy var poetLogo: UIImageView = {
        let poetLogo = UIImageView(frame: viewInitRect)
        poetLogo.image = UIImage(named: "poetic_time_poem_card_poet_logo")
        poetLogo.contentMode = .scaleAspectFill
        return poetLogo
    }()
    
    // 诗人名label
    lazy var poetLabel: UILabel = {
        let poetLabel = UILabel()
        poetLabel.textColor = .white
        poetLabel.numberOfLines = 0
        poetLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 8)
        return poetLabel
    }()
    
    // 诗名label
    lazy var poemLabel: UILabel = {
        let poemLabel = UILabel()
        poemLabel.textAlignment = .center
        poemLabel.numberOfLines = 0
        poemLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 24)
        return poemLabel
    }()
    
    // 收藏按钮
    lazy var starButton: UIButton = {
        let starButton = UIButton()
        starButton.backgroundColor = .clear
        starButton.imageView?.contentMode = .scaleAspectFit
        starButton.addTarget(self, action: #selector(changeStarState), for: .touchUpInside)
        return starButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        poetLogo.addSubview(poetLabel)
        contentView.addSubview(poetLogo)
        contentView.addSubview(poemLabel)
        contentView.addSubview(starButton)
        
        poetLogo.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(52)
            make.width.equalTo(14)
        }
        
        poetLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().offset(4)
        }
        
        poemLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
        
        starButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.height.width.equalTo(24)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func changeStarState(sender: UIButton) {
        ButtonAnimate(sender)
        // 获取内存中对应数据的index
        let index = poemData.firstIndex { poem in
            poem.poemId == _poemId
        }
        guard let index = index else { return }
        let poem = poemData.filter { $0.poemId == _poemId }
        // 修改内存中数据
        poemData[index] = Poem(poemId: poem.first?.poemId ?? "", poemName: poem.first?.poemName ?? "", poetId: poem.first?.poetId ?? "", dynastyId: poem.first?.dynastyId ?? "", poemBody: poem.first?.poemBody ?? "", poemStar: !(poem.first?.poemStar ?? true))
        let isStar = poemData[index].poemStar ? "is" : "no"
        // 修改UI
        starButton.setImage(UIImage(named: "poetic_time_poem_card_\(isStar)_star_image"), for: .normal)
        // 存入数据库
        let info = DBInfo(poemId: poemData[index].poemId, poemName: poemData[index].poemName, poetId: poemData[index].poetId, dynastyId: poemData[index].dynastyId, poemBody: poemData[index].poemBody, poemStar: poemData[index].poemStar)
        PoeticTimeDao.updateElement(info: info)
    }
}
