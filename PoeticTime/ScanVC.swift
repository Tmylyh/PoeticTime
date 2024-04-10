//
//  ScanVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/20.
//

import UIKit
import SnapKit

class ScanVC: UIViewController {
    
    // 背景
    lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(frame: viewInitRect)
        backgroundImageView.image = UIImage(named: "poetic_time_user_back_ground_image")
        backgroundImageView.contentMode = .scaleAspectFit
        return backgroundImageView
    }()
    
    lazy var contentImageView: UIImageView = {
        let contentImageView = UIImageView(frame: viewInitRect)
        contentImageView.contentMode = .scaleAspectFit
        contentImageView.backgroundColor = .clear
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        return contentImageView
    }()
    
    // 大标题
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "幻境斗诗"
        titleLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 32)
        titleLabel.textColor = "#15948B".pt_argbColor
        return titleLabel
    }()
    
    // 规则
    lazy var ruleTextView: UITextView = {
        let ruleTextView = UITextView()
        ruleTextView.isEditable = false
        ruleTextView.isSelectable = false
        ruleTextView.text = "部首寻诗\n1.玩家需观察散乱之偏旁部首，联想并合之以为古诗词句。\n2.时限之内答对，即通关。逾二十秒者，则视为超时。\n\n诗境寻章\n1.玩家需于AR幻境之中，寻觅并点击与古诗词紧密相关的物件。\n2.待物件悉数点毕，依据所见猜度完整诗句。\n3.于答题框内输入所猜诗句，若合于原意，则继续探索；若有出入，可再试之。\n4.须于限定之时内答出所有题目，方得通关。\n\n祈愿君游戏愉快，尽享探索古诗词之雅趣～"
        ruleTextView.backgroundColor = "#F0FCFA".pt_argbColor
        ruleTextView.layer.cornerRadius = 20
        ruleTextView.layer.masksToBounds = true
        ruleTextView.textColor = .black
        ruleTextView.isScrollEnabled = true
        ruleTextView.showsVerticalScrollIndicator = false
        ruleTextView.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 24)
        return ruleTextView
    }()
    
    // 开始游戏
    lazy var playButton: UIButton = {
        let playButton = UIButton()
        playButton.layer.cornerRadius = 20
        playButton.layer.masksToBounds = true
        playButton.addTarget(self, action: #selector(present2AR), for: .touchUpInside)
        playButton.backgroundColor = "#72A3A0".pt_argbColor
        playButton.setTitle("进入幻境", for: .normal)
        return playButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setBaseUI()
    }
    
    // 配制view
    func setBaseUI() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        view.addSubview(backgroundImageView)
        view.addSubview(contentImageView)
        contentImageView.addSubview(titleLabel)
        view.addSubview(ruleTextView)
        view.addSubview(playButton)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        NSLayoutConstraint.activate([
            contentImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -ptTabBarHeight),
            contentImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 88)
        ])
        
        playButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-ptTabBarHeight - 32)
            make.height.equalTo(44)
            make.width.equalTo(120)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        ruleTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60 + 88)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(playButton.snp.top).offset(-16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    @objc func present2AR(sender: UIButton) {
        ButtonAnimate(sender)
        let ARMenuVC = PtARMenuVC()
        ARMenuVC.modalPresentationStyle = .fullScreen
        present(ARMenuVC, animated: true)
    }
}
