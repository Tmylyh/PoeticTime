//
//  PoetAnswerVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/31.
//

import UIKit
import SnapKit
import Lottie
import Speech

class PoetAnswerVC: UIViewController {
    
    // 诗人id
    var poetId = ""
    
    // 总共的诗词对话数据
    var poems: [[String : [[String]]]] = []
    
    // 当前抽到的诗下标
    var currentPoemIndex = 0
    
    // 当前抽到的句子下标
    var currentSentenceIndex = 0
    
    // 使用前半句还是后半句作为已经显示的地方
    var currentHalfSentenceIndex = 0
    
    // 已经抽到过的诗的句子的下标
    var existPoemIndex: [Int : [Int]] = [:]
    
    // 已经提示次数
    var tipsCount = 0
    
    // 答对次数
    var answerRightCount = 0
    
    // 需要答对次数
    var answerNeedRightCount = 10
    
    // 用于进行语音识别的对象，通过指定地区来创建
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    
    // 用于发送语音数据并接收识别结果的请求对象
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    // 用于管理语音识别任务的对象
    var recognitionTask: SFSpeechRecognitionTask?
    
    // 用于处理音频输入和输出的引擎对象
    let audioEngine = AVAudioEngine()
    
    // 语音识别到的文本
    var soundText: String {
        get {
            return ""
        }
        set {
            if self.currentHalfSentenceIndex == 0 {
                self.poemAnswerTextField2.text = newValue
                self.poemAnswerTextField2.textColor = .black
            } else {
                self.poemAnswerTextField1.text = newValue
                self.poemAnswerTextField1.textColor = .black
            }
        }
    }
    
    init(poetId: String) {
        super.init(nibName: nil, bundle: nil)
        self.poetId = poetId
    }
    
    // 背景图
    lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(frame: viewInitRect)
        backgroundImageView.image = UIImage(named: "poetic_time_poet_answer_background_image")
        backgroundImageView.contentMode = .scaleAspectFit
        return backgroundImageView
    }()
    
    // 诗人头像
    lazy var poetImageView: UIImageView = {
        let poetImageView = UIImageView(frame: viewInitRect)
        poetImageView.image = UIImage(named: "poetic_time_poet_image")
        poetImageView.contentMode = .scaleAspectFit
        poetImageView.backgroundColor = .clear
        return poetImageView
    }()
    
    // 声音动画
    lazy var poetSoundAnimationView: LottieAnimationView = {
        let poetSoundAnimationView = LottieAnimationView(name: "soundAnimation")
        return poetSoundAnimationView
    }()
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "poetic_time_back_image"), for: .normal)
        backButton.addTarget(self, action: #selector(dismissCurrentVC), for: .touchUpInside)
        return backButton
    }()
    
    // 答题区域
    lazy var answerQuestionContent: UIView = {
        let answerQuestionContent = UIView(frame: viewInitRect)
        answerQuestionContent.layer.shadowOffset = CGSize(width: 0, height: 2)
        answerQuestionContent.layer.cornerRadius = 20
        answerQuestionContent.layer.borderWidth = 2
        answerQuestionContent.layer.borderColor = UIColor.gray.cgColor
        answerQuestionContent.layer.shadowRadius = 2
        answerQuestionContent.layer.shadowColor = UIColor.gray.cgColor
        answerQuestionContent.layer.shadowOpacity = 0.5
        return answerQuestionContent
    }()
    
    // 需要答题的句子标记1
    lazy var answerSentenceTag1: UIView = {
        let answerSentenceTag1 = UIView(frame: viewInitRect)
        answerSentenceTag1.backgroundColor = "#7EB5B1".pt_argbColor
        return answerSentenceTag1
    }()
    
    // 需要答题的句子标记2
    lazy var answerSentenceTag2: UIView = {
        let answerSentenceTag2 = UIView(frame: viewInitRect)
        answerSentenceTag2.backgroundColor = "#7EB5B1".pt_argbColor
        return answerSentenceTag2
    }()
    
    // 需要答题的句子下划线1
    lazy var answerSentenceLine1: UIView = {
        let answerSentenceLine1 = UIView(frame: viewInitRect)
        answerSentenceLine1.backgroundColor = .black
        return answerSentenceLine1
    }()
    
    // 需要答题的句子下划线2
    lazy var answerSentenceLine2: UIView = {
        let answerSentenceLine2 = UIView(frame: viewInitRect)
        answerSentenceLine2.backgroundColor = .black
        return answerSentenceLine2
    }()
    
    // 诗名
    lazy var poemNameLabel: UILabel = {
        let poemNameLabel = UILabel()
        poemNameLabel.textColor = .black
        poemNameLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 14)
        poemNameLabel.text = "——《\(String(describing: poems[currentPoemIndex].keys.first ?? ""))》"
        return poemNameLabel
    }()
    
    // 下一题按钮
    lazy var nextQuestionButton: UIButton = {
        let nextQuestionButton = UIButton()
        nextQuestionButton.backgroundColor = "#7EB5B1".pt_argbColor
        nextQuestionButton.layer.cornerRadius = 16
        nextQuestionButton.setTitle("下一题", for: .normal)
        nextQuestionButton.setTitleColor(.white, for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(commitAnswer))
        nextQuestionButton.addGestureRecognizer(tap)
        return nextQuestionButton
    }()
    
    // 提示按钮
    lazy var tipsButton: UIButton = {
        let tipsButton = UIButton()
        tipsButton.backgroundColor = .clear
        tipsButton.setTitle("查看提示", for: .normal)
        tipsButton.titleLabel?.font = .systemFont(ofSize: 14)
        tipsButton.setTitleColor(.tertiaryLabel, for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tipHandle))
        tipsButton.addGestureRecognizer(tap)
        return tipsButton
    }()
    
    // 提示按钮图
    lazy var tipsImageButton: UIButton = {
        let tipsImageButton = UIButton()
        tipsImageButton.backgroundColor = .clear
        tipsImageButton.setImage(UIImage(named: "poetic_time_poet_answer_tips_bumb_image"), for: .normal)
        tipsImageButton.imageView?.contentMode = .scaleAspectFit
        let tap = UITapGestureRecognizer(target: self, action: #selector(tipHandle))
        tipsImageButton.addGestureRecognizer(tap)
        return tipsImageButton
    }()
    
    // 第一句诗
    lazy var poemAnswerTextField1: UITextField = {
        let poemAnswerTextField1 = UITextField()
        poemAnswerTextField1.text = "日照香炉生紫烟"
        poemAnswerTextField1.delegate = self
        // 设置 Return 键的文字为 "完成"
        poemAnswerTextField1.returnKeyType = .done
        poemAnswerTextField1.font = UIFont(name: ZiTi.pmzd.rawValue, size: 29)
        return poemAnswerTextField1
    }()
    
    // 第二句诗
    lazy var poemAnswerTextField2: UITextField = {
        let poemAnswerTextField2 = UITextField()
        poemAnswerTextField2.text = "遥看瀑布挂前川"
        poemAnswerTextField2.delegate = self
        // 设置 Return 键的文字为 "完成"
        poemAnswerTextField2.returnKeyType = .done
        poemAnswerTextField2.font = UIFont(name: ZiTi.pmzd.rawValue, size: 29)
        return poemAnswerTextField2
    }()
    
    // 语音回答按钮
    lazy var poemAnswerSoundButton: UIButton = {
        let poemAnswerSoundButton = UIButton()
        poemAnswerSoundButton.setTitle("长按识别", for: .normal)
        poemAnswerSoundButton.setTitleColor(.black, for: .normal)
        poemAnswerSoundButton.backgroundColor = .yellow
        poemAnswerSoundButton.layer.cornerRadius = 20
        poemAnswerSoundButton.isEnabled = false
        poemAnswerSoundButton.addTarget(self, action: #selector(touchDownHandle), for: .touchDown)
        poemAnswerSoundButton.addTarget(self, action: #selector(touchUpInsideHandle), for: .touchUpInside)
        poemAnswerSoundButton.addTarget(self, action: #selector(touchUpOutsideHandle), for: .touchUpOutside)
        return poemAnswerSoundButton
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getQuestionData()
        setAnswerViewUI()
        getCurrentQuestion()
        setQuestionUI()
        // 判断网络状况
        if !isReachable {
            // 回主线程操作
            OperationQueue.main.addOperation {
                self.poemAnswerSoundButton.setTitle("连网识别", for: .normal)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let speechRecognizer = speechRecognizer else { return }
        speechRecognizer.delegate = self
        
        // 请求用户授权
        SFSpeechRecognizer.requestAuthorization { authStatus in

            // 界面更新必须回到主线程操作
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.poemAnswerSoundButton.isEnabled = true
                    
                case .denied:
                    self.poemAnswerSoundButton.isEnabled = false
                    self.poemAnswerSoundButton.setTitle("权限已拒绝", for: .disabled)
                    
                case .restricted:
                    self.poemAnswerSoundButton.isEnabled = false
                    self.poemAnswerSoundButton.setTitle("设备不支持", for: .disabled)
                    
                case .notDetermined:
                    self.poemAnswerSoundButton.isEnabled = false
                    self.poemAnswerSoundButton.setTitle("尚未授权", for: .disabled)
                    
                default:
                    self.poemAnswerSoundButton.isEnabled = false
                }
            }
        }
    }
    
    // 配制UI
    func setAnswerViewUI() {
        self.view.backgroundColor = .white
        // 添加手势识别器来隐藏键盘
        let hideKeyBoardTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // 将手势识别器添加到视图上
        view.addGestureRecognizer(hideKeyBoardTap)
        view.addSubview(backgroundImageView)
        view.addSubview(backButton)
        view.addSubview(poetImageView)
        view.addSubview(poetSoundAnimationView)
        view.addSubview(answerQuestionContent)
        view.addSubview(poemAnswerSoundButton)
        answerQuestionContent.addSubview(answerSentenceTag1)
        answerQuestionContent.addSubview(answerSentenceLine1)
        answerQuestionContent.addSubview(answerSentenceTag2)
        answerQuestionContent.addSubview(answerSentenceLine2)
        answerQuestionContent.addSubview(poemNameLabel)
        answerQuestionContent.addSubview(nextQuestionButton)
        answerQuestionContent.addSubview(tipsImageButton)
        answerQuestionContent.addSubview(tipsButton)
        answerQuestionContent.addSubview(poemAnswerTextField1)
        answerQuestionContent.addSubview(poemAnswerTextField2)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(44)
            make.width.height.equalTo(32)
        }
        
        poetImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(66)
            make.height.width.equalTo(78)
        }
        
        poetSoundAnimationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(poetImageView.snp.bottom).offset(2)
            make.height.equalTo(33)
            make.width.equalTo(66)
        }
        
        answerQuestionContent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(173)
            make.width.equalTo(334)
            make.height.equalTo(432)
        }
        
        poemAnswerSoundButton.snp.makeConstraints { make in
            make.top.equalTo(answerQuestionContent.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(44)
        }
        
        answerSentenceTag1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(129)
            make.left.equalToSuperview().offset(22)
            make.width.equalTo(6)
            make.height.equalTo(33)
        }
        
        answerSentenceLine1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(160)
            make.left.equalToSuperview().offset(64)
            make.width.equalTo(230)
            make.height.equalTo(2)
        }
        
        answerSentenceTag2.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(189)
            make.left.equalToSuperview().offset(22)
            make.width.equalTo(6)
            make.height.equalTo(33)
        }
        
        answerSentenceLine2.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(220)
            make.left.equalToSuperview().offset(64)
            make.width.equalTo(230)
            make.height.equalTo(2)
        }
        
        poemNameLabel.snp.makeConstraints { make in
            make.top.equalTo(answerSentenceLine2.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
        }
        
        nextQuestionButton.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview().offset(-8)
            make.width.equalTo(136)
            make.height.equalTo(31)
        }
        
        tipsImageButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
        tipsButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(82)
            make.height.equalTo(20)
        }
        
        poemAnswerTextField1.snp.makeConstraints { make in
            make.left.equalTo(answerSentenceLine1.snp.left)
            make.top.equalTo(answerSentenceTag1.snp.top).offset(-2)
        }

        poemAnswerTextField2.snp.makeConstraints { make in
            make.left.equalTo(answerSentenceLine2.snp.left)
            make.top.equalTo(answerSentenceTag2.snp.top).offset(-2)
        }
    }
}

extension PoetAnswerVC: UITextFieldDelegate {
    // 编辑时保持字体黑色
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.textColor = .black
    }
    
    // 当用户按下 Return 键时调用
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 取消 textField 的第一响应者状态，即结束编辑
        textField.resignFirstResponder()
        return true
    }
}
