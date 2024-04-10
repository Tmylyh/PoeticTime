//
//  DynastyUserPoemCell.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/3.
//

import UIKit
import SnapKit

class DynastyUserPoemCell: UITableViewCell {
    
    // 诗名
    var userPoemName = ""
    // 日期
    var userPoemDate: Double = 0
    // 朝代
    var userPoemDynasty = ""
    
    // 是否来自个人页面
    var isFromUserVC: Bool = false

    // 诗名Label
    lazy var poemLabel: UILabel = {
        let poemLabel = UILabel()
        poemLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 22)
        return poemLabel
    }()
    
    // 诗的日期
    lazy var poemDateLabel: UILabel = {
        let poemDateLabel = UILabel()
        poemDateLabel.font = .systemFont(ofSize: 14)
        return poemDateLabel
    }()
    
    // 朝代Label
    lazy var poemDynastyLabel: UILabel = {
        let poemDynastyLabel = UILabel()
        poemDynastyLabel.font = .systemFont(ofSize: 14)
        return poemDynastyLabel
    }()
    
    // 初始化数据
    func initData(index: Int, userPoemCurrentData: [UserPoem]) {
        self.userPoemDynasty = userPoemCurrentData[index].userPoemDynasty
        self.userPoemName = userPoemCurrentData[index].userPoemName
        self.userPoemDate = userPoemCurrentData[index].userPoemDate
        poemDynastyLabel.text = userPoemDynasty
        poemLabel.text = userPoemName
        poemDateLabel.text = getDateString(userPoemDate: userPoemDate)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        if isFromUserVC {
            contentView.backgroundColor = .white
        } else {
            contentView.backgroundColor = .white            
        }
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 25
        // 内边距
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        contentView.addSubview(poemLabel)
        contentView.addSubview(poemDateLabel)
        contentView.addSubview(poemDynastyLabel)
        
        poemLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        poemDynastyLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        poemDateLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}
