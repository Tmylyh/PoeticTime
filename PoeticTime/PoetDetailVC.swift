//
//  PoetDetailVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/30.
//

import UIKit
import Hero
import SnapKit

class PoetDetailVC: UIViewController {
    
    var poetName = ""
    
    // 背景
    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(frame: viewInitRect)
        backgroundImageView.image = UIImage(named: "poetic_time_study_background")
        backgroundImageView.contentMode = .scaleAspectFit
        return backgroundImageView
    }()
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "poetic_time_back_image"), for: .normal)
        backButton.addTarget(self, action: #selector(dismissCurrentVC), for: .touchUpInside)
        return backButton
    }()
    
    // 诗人Label
    lazy var poetLabel: UILabel = {
        let poetLabel = UILabel()
        poetLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 24)
        poetLabel.text = poetName
        poetLabel.textAlignment = .center
        poetLabel.textColor = .black
        return poetLabel
    }()
    
    // 诗人头像
    lazy var poetImageView: UIImageView = {
        let poetImageView = UIImageView(frame: viewInitRect)
        poetImageView.image = UIImage(named: "poetic_time_poet_image")
        poetImageView.backgroundColor = .clear
        return poetImageView
    }()
    
    // 诗人介绍
    lazy var poetTextView: UITextView = {
        let poetTextView = UITextView()
        // 不能编辑
        poetTextView.isEditable = false
        // 不能选中
        poetTextView.isSelectable = false
        poetTextView.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 16)
        poetTextView.backgroundColor = "#7EB5B1".pt_argbColor
        poetTextView.layer.masksToBounds = true
        poetTextView.layer.cornerRadius = 20
        poetTextView.textColor = .white
        poetTextView.showsVerticalScrollIndicator = false
        let poet = poetData.filter { $0.poetName == poetName }
        poetTextView.text = poet.first?.poetInfo
        return poetTextView
    }()
    
    // 作品列表按钮
    lazy var poemListButton: UIButton = {
        let poemListButton = UIButton()
        poemListButton.setImage(UIImage(named: "poetic_time_poet_poem_list_button_image"), for: .normal)
        poemListButton.imageView?.contentMode = .scaleAspectFit
        poemListButton.imageView?.layer.borderColor = UIColor.black.cgColor
        poemListButton.imageView?.layer.borderWidth = 1
        poemListButton.imageView?.layer.cornerRadius = 20
        // 去掉按钮原生的点击变暗效果
        poemListButton.adjustsImageWhenHighlighted = false
        poemListButton.addTarget(self, action: #selector(presentPoemListVC), for: .touchUpInside)
        return poemListButton
    }()
    
    // 作品列表Label
    lazy var poemListLabel: UILabel = {
        let poemListLabel = UILabel()
        poemListLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 32)
        poemListLabel.text = "诗卷珍藏"
        poemListLabel.textColor = .white
        return poemListLabel
    }()
    
    // 对诗按钮
    lazy var answerButton: UIButton = {
        let answerButton = UIButton()
        answerButton.setImage(UIImage(named: "poetic_time_poet_answer_button_image"), for: .normal)
        answerButton.imageView?.contentMode = .scaleAspectFit
        answerButton.imageView?.layer.borderColor = UIColor.black.cgColor
        answerButton.imageView?.layer.borderWidth = 1
        answerButton.imageView?.layer.cornerRadius = 20
        answerButton.addTarget(self, action: #selector(presentAnswerPoemVC), for: .touchUpInside)
        // 去掉按钮原生的点击变暗效果
        answerButton.adjustsImageWhenHighlighted = false
        return answerButton
    }()
    
    // 对诗Label
    lazy var answerLabel: UILabel = {
        let answerLabel = UILabel()
        answerLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 32)
        answerLabel.text = "斗\n诗"
        answerLabel.numberOfLines = 0
        return answerLabel
    }()
    
    // 聊天按钮
    lazy var chatButton: UIButton = {
        let chatButton = UIButton()
        chatButton.setImage(UIImage(named: "poetic_time_poet_chat_button_image"), for: .normal)
        chatButton.imageView?.contentMode = .scaleAspectFit
        chatButton.imageView?.layer.borderColor = UIColor.black.cgColor
        chatButton.imageView?.layer.borderWidth = 1
        chatButton.imageView?.layer.cornerRadius = 20
        chatButton.addTarget(self, action: #selector(presentChatVC), for: .touchUpInside)
        // 去掉按钮原生的点击变暗效果
        chatButton.adjustsImageWhenHighlighted = false
        return chatButton
    }()
    
    // 聊天Label
    lazy var chatLabel: UILabel = {
        let chatLabel = UILabel()
        chatLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 32)
        chatLabel.text = "茶\n叙"
        chatLabel.numberOfLines = 0
        return chatLabel
    }()
    
    // 跳转到作品列表
    @objc func presentPoemListVC(sender: UIButton) {
        ButtonAnimate(sender)
        sender.hero.id = "poetList"
        let poet = poetData.filter { $0.poetName == poetName }
        guard let poetId = poet.first?.poetId else { return }
        let poetPoemListVC = PoetPoemListVC(poetId: poetId)
        poetPoemListVC.poetName = poetName
        // 查询诗人诗词
        let poemsWithPoet = poemData.filter { $0.poetId == poetId }
        poetPoemListVC.poemsWithPoetData = poemsWithPoet
        poetPoemListVC.view.hero.id = "poetList"
        poetPoemListVC.hero.isEnabled = true
        poetPoemListVC.heroModalAnimationType = .zoom
        poetPoemListVC.modalPresentationStyle = .fullScreen
        present(poetPoemListVC, animated: true)
    }
    
    // 跳转到对诗
    @objc func presentAnswerPoemVC(sender: UIButton) {
        ButtonAnimate(sender)
        sender.hero.id = "poetAnswer"
        let poet = poetData.filter { $0.poetName == poetName }
        guard let poetId = poet.first?.poetId else { return }
        let poetAnswerVC = PoetAnswerVC(poetId: poetId)
        poetAnswerVC.poetName = self.poetName
        // hero 属性可能会影响视图层级结构，而设置poetName会给label，label根据内容布局，所以poetName的设置必须在上面
        poetAnswerVC.view.hero.id = "poetAnswer"
        poetAnswerVC.hero.isEnabled = true
        poetAnswerVC.heroModalAnimationType = .zoom
        poetAnswerVC.modalPresentationStyle = .fullScreen
        present(poetAnswerVC, animated: true)
    }
    
    // 跳转到聊天
    @objc func presentChatVC(sender: UIButton) {
        ButtonAnimate(sender)
        sender.hero.id = "poetChat"
        let poet = poetData.filter { $0.poetName == poetName }
        guard let poetId = poet.first?.poetId else { return }
        let poetChatVC = PoetChatVC(poetId: poetId)
        poetChatVC.poetName = poetName
        poetChatVC.view.hero.id = "poetChat"
        poetChatVC.hero.isEnabled = true
        poetChatVC.heroModalAnimationType = .zoom
        poetChatVC.modalPresentationStyle = .fullScreen
        present(poetChatVC, animated: true)
    }
    
    // dimiss当前View
    @objc func dismissCurrentVC() {
        hero.dismissViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPoetDetailViewUI()
        // 清空数据
        if isReachable {
            clearRequest()
        }
    }
    
    // 配制UI
    func setPoetDetailViewUI() {
        self.view.backgroundColor = .white
        view.addSubview(backgroundImageView)
        view.addSubview(backButton)
        view.addSubview(poetLabel)
        view.addSubview(poetImageView)
        view.addSubview(poetTextView)
        view.addSubview(poemListButton)
        poemListButton.addSubview(poemListLabel)
        view.addSubview(answerButton)
        answerButton.addSubview(answerLabel)
        view.addSubview(chatButton)
        chatButton.addSubview(chatLabel)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(44)
            make.height.width.equalTo(32)
        }
        
        poetLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarHeight)
        }
        
        poetImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(35)
            make.top.equalToSuperview().offset(110)
            make.width.height.equalTo(113)
        }
        
        poetTextView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(160)
            make.top.equalToSuperview().offset(110)
            make.width.equalTo(190)
            make.height.equalTo(228)
        }
        
        poemListButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.top.equalTo(poetTextView.snp.bottom).offset(21)
            make.width.equalTo(190)
            make.right.equalToSuperview().offset(-28)
        }
        
        poemListLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        answerButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.top.equalTo(poemListButton.snp.bottom).offset(21)
            make.width.equalTo(136)
            make.height.equalTo(190)
        }

        answerLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        chatButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-28)
            make.top.equalTo(poemListButton.snp.bottom).offset(21)
            make.width.equalTo(136)
            make.height.equalTo(190)
        }

        chatLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
