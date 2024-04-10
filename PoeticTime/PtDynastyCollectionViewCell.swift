//
//  PtDynastyCollectionViewCell.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/24.
//

import UIKit
import SnapKit

class PtDynastyCollectionViewCell: UICollectionViewCell {
    
    public var activeIndexPath: IndexPath? = nil { // 当前正在活跃的cell的index
        didSet {
            if let activeIndexPath = activeIndexPath, activeIndexPath != oldValue {
                activeIndexPathDidChangeBlock?(activeIndexPath)
            }
        }
    }
    
    public var activeIndexPathDidChangeBlock: ((IndexPath) -> Void)? = nil
    
    /// 活跃的cell颜色
    public func changeActiveColor() {
        backColorView.backgroundColor = "E8EEE5".pt_argbColor
        contentColorView.backgroundColor = colorData["StudyVC_separateLeftLine_\(currentDynasty.rawValue)_color1"]?.pt_argbColor
    }
    
    /// 重置
    public func resetColor() {
        backColorView.backgroundColor = "D8D8D8".pt_argbColor
        contentColorView.backgroundColor = "A8A6A0".pt_argbColor
        self.transform = CGAffineTransform.identity
    }
    
    /// 放大cell
    public func bigFactor() {
        self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    }
    
    public var dynastyText:String {
        get {
            return dynastyLabel.text ?? ""
        }
        set {
            // 每个字符后添加换行符，使文字纵向排列
            dynastyLabel.text = verticalText(text: newValue)
        }
    }
    
    // 最底部的颜色
    private lazy var backColorView: UIView = {
        let backColorView = UIView(frame: viewInitRect)
        backColorView.backgroundColor = "#D8D8D8".pt_argbColor
        backColorView.layer.cornerRadius = 16
        return backColorView
    }()
    
    // 装字的容器
    private lazy var contentColorView: UIView = {
        let contentColorView = UIView(frame: viewInitRect)
        contentColorView.backgroundColor = "#A8A6A0".pt_argbColor
        contentColorView.layer.cornerRadius = 12
        return contentColorView
    }()
    
    // 文字
    private lazy var dynastyLabel: UILabel = {
        let dynastyLabel = UILabel()
        dynastyLabel.text = ""
        dynastyLabel.textAlignment = .center
        dynastyLabel.textColor = .white
        dynastyLabel.numberOfLines = 0
        dynastyLabel.font = UIFont(name: ZiTi.pmzd.rawValue, size: 16)
        return dynastyLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backColorView.addSubview(contentColorView)
        backColorView.addSubview(dynastyLabel)
        contentView.addSubview(backColorView)
        
        backColorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentColorView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(4)
            make.bottom.right.equalToSuperview().offset(-4)
        }
        
        dynastyLabel.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(54)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
