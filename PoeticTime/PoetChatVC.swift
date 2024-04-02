//
//  PoetChatVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/1.
//

import UIKit
import MessageKit
import SnapKit
import InputBarAccessoryView

// 响应者
struct Sender: SenderType {
    // id
    var senderId: String
    // 名字
    var displayName: String
}

// 信息体
struct Message: MessageType {
    // 响应者
    var sender: SenderType
    // id
    var messageId: String
    // 时间
    var sentDate: Date
    // 类型
    var kind: MessageKind
}


class PoetChatVC: MessagesViewController {
    
    // 用户
    let currentUser = Sender(senderId: "user", displayName: "李跃行")
    
    // 诗人
    var poetUser: Sender?
    
    // 消息总和
    var messages = [Message]()
    
    // 诗人id
    var poetId = ""
    
    // 诗人名
    var poetName = ""
    
    // 当前发送信息，默认值定为问你是谁，用于首次请求的打招呼信息
    var currentMessage = "你是谁?"
    
    // 当前得到的回答
    var currentAnswer = ""
    
    // 当前诗人messageid
    var currentPoetMessageid = ""
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "poetic_time_back_image"), for: .normal)
        backButton.addTarget(self, action: #selector(dismissCurrentVC), for: .touchUpInside)
        return backButton
    }()
    
    // 诗人头像
    lazy var poetImageView: UIImageView = {
        let poetImageView = UIImageView(frame: viewInitRect)
        poetImageView.image = UIImage(named: "poetic_time_poet_image")
        poetImageView.contentMode = .scaleAspectFit
        poetImageView.backgroundColor = .clear
        return poetImageView
    }()
    
    // 诗人名
    lazy var poetLabel: UILabel = {
        let poetLabel = UILabel()
        poetLabel.textColor = .black
        poetLabel.text = poetName
        poetLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 20)
        return poetLabel
    }()
    
    // 收起键盘的点击View
    lazy var tapView: UIView = {
        let tapView = UIView(frame: CGRect(x: 0, y: 0, width: Int(Bounds.width), height: Int(Bounds.height) / 2 + 20))
        // 添加手势识别器来隐藏键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoardTap))
        // 将手势识别器添加到视图上
        tapView.addGestureRecognizer(tapGesture)
        tapView.isUserInteractionEnabled = true
        tapView.backgroundColor = .clear
        return tapView
    }()
    
    init(poetId: String) {
        super.init(nibName: nil, bundle: nil)
        self.poetId = poetId
        let poetName = poetData.filter { poetId == $0.poetId }.first?.poetName ?? "未知诗人"
        self.poetName = poetName
        poetUser = Sender(senderId: poetId, displayName: poetName)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 配制UI
        setChatVCUI()
        
        // 清理历史对话
        clearRequest()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        // 为了监听键盘升起
        messageInputBar.inputTextView.delegate = self
        
        // 获取诗人第一句打招呼
        if isReachable {
            self.requestStreamPoetAnswer()
        }
    }
    
    // 配制UI
    func setChatVCUI() {
        view.addSubview(tapView)
        view.addSubview(backButton)
        view.addSubview(poetImageView)
        view.addSubview(poetLabel)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(46)
            make.width.height.equalTo(32)
        }
        
        poetImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(60)
            make.top.equalToSuperview().offset(44)
            make.width.height.equalTo(36)
        }
        
        poetLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(108)
            make.top.equalToSuperview().offset(46)
            make.height.equalTo(32)
        }
    }
    
    // 隐藏键盘
    @objc func hideKeyBoardTap() {
        resignFirstResponder()
        becomeFirstResponder()
        tapView.isHidden = true
    }
    
    // dimiss当前View
    @objc func dismissCurrentVC() {
        self.inputAccessoryView?.removeFromSuperview()
        hero.dismissViewController()
    }
}

extension PoetChatVC: InputBarAccessoryViewDelegate, UITextViewDelegate {
    
    // 输入栏
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // 用户点击了发送按钮，`text` 参数包含了输入栏中的文本
        
        // 这里处理发送消息的逻辑，将消息添加到数据源并刷新界面
        // 发送完成后清空输入栏的文本
        inputBar.inputTextView.text = ""
        let message = Message(sender: currentUser, messageId: "\(UUID())", sentDate: Date(), kind: .text(text))
        self.currentMessage = text
        if isReachable {
            // 新增信息
            insertMessage(message)
        } else {
            guard let poetUser = poetUser else { return }
            let message = Message(sender: poetUser, messageId: "\(UUID())", sentDate: Date(), kind: .text("联网后再与阁下交谈"))
            // 新增信息
            insertMessage(message)
        }
    }
    
    // 监听键盘唤起
    func textViewDidBeginEditing(_ textView: UITextView) {
        tapView.isHidden = false
    }
}
