//
//  PtPoemCell.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/30.
//

import UIKit
import SnapKit

class PtPoemCell: UICollectionViewCell {
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        poetLogo.addSubview(poetLabel)
        contentView.addSubview(poetLogo)
        contentView.addSubview(poemLabel)
        
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
