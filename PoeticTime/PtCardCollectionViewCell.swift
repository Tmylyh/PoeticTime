//
//  PtCardCollectionViewCell.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/23.
//

import UIKit
import SnapKit

class PtCardCollectionViewCell: UICollectionViewCell {
    
    private lazy var contentImageView: UIImageView = {
        let contentImageView = UIImageView(frame: viewInitRect)
        contentImageView.image = UIImage(named: "poetic_time_study_tang_card_image")
        contentImageView.contentMode = .scaleAspectFit
        return contentImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 20
        contentView.addSubview(contentImageView)
        
        contentImageView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
