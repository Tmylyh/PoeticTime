//
//  PoetAnswerVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/31.
//

import UIKit
import Lottie
import Speech
import Alamofire

class PoetAnswerVC: UIViewController {
    
    // 诗人id
    var poetId = ""
    
    // 诗人名
    var poetName = ""
    
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
    
    // 播放器
    var audioPlayer: AVAudioPlayer?
    
    // 当前题目回答结果
    var currentCheck: Bool {
        get {
            return checkLabel.text == "妙对如流" ? true : false
        }
        set {
            if newValue {
                checkLabel.text = "妙对如流"
                checkLabel.textColor = .green
            } else {
                checkLabel.text = "再炼诗才"
                checkLabel.textColor = .red
            }
        }
    }
    
    // 用于进行语音识别的对象，通过指定地区来创建
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    
    // 用于发送语音数据并接收识别结果的请求对象
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    // 用于管理语音识别任务的对象
    var recognitionTask: SFSpeechRecognitionTask?
    
    // 用于处理音频输入和输出的引擎对象
    let audioEngine = AVAudioEngine()
    
    // 语音按钮持续识别计时器
    var recordTimer: Timer?
    
    // 取消录音文本
    var isCancelRecord: Bool = false
    
    // 音频请求
    var request: DataRequest?
    
    // 指定文本音频文件的URL
    let audioFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("audio_text.wav")
    
    // 诗人语音持续播放计时器
    var audioTimer: Timer?
    
    // 语音识别到的文本
    var soundText: String {
        get {
            return currentHalfSentenceIndex == 0 ? self.poemAnswerTextField2.text ?? "" : self.poemAnswerTextField1.text ?? ""
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
        backgroundImageView.image = UIImage(named: "poetic_time_study_\(currentDynasty.rawValue)_background")
        backgroundImageView.contentMode = .scaleAspectFit
        return backgroundImageView
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
        poetImageView.image = UIImage(named: "poetic_time_poet_image_\(poetId)") ?? UIImage(named: "poetic_time_poet_image_dumu")
        poetImageView.contentMode = .scaleAspectFit
        poetImageView.layer.masksToBounds = true
        poetImageView.layer.cornerRadius = 38
        poetImageView.layer.borderWidth = 1
        poetImageView.layer.borderColor = UIColor.black.cgColor
        poetImageView.backgroundColor = .clear
        return poetImageView
    }()
    
    // 声音动画
    lazy var poetSoundAnimationView: LottieAnimationView = {
        let poetSoundAnimationView = LottieAnimationView(name: "soundAnimation")
        return poetSoundAnimationView
    }()
    
    // 录音动画
    lazy var poetRecordAnimationView: LottieAnimationView = {
        let poetRecordAnimationView = LottieAnimationView(name: "soundAnimation")
        poetRecordAnimationView.isUserInteractionEnabled = false
        poetRecordAnimationView.isHidden = true
        return poetRecordAnimationView
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
        answerSentenceTag1.backgroundColor = colorData["DynastyVC_poetTextView_\(currentDynasty.rawValue)_color1"]?.pt_argbColor
        return answerSentenceTag1
    }()
    
    // 需要答题的句子标记2
    lazy var answerSentenceTag2: UIView = {
        let answerSentenceTag2 = UIView(frame: viewInitRect)
        answerSentenceTag2.backgroundColor = colorData["DynastyVC_poetTextView_\(currentDynasty.rawValue)_color1"]?.pt_argbColor
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
        nextQuestionButton.backgroundColor = colorData["DynastyVC_poetTextView_\(currentDynasty.rawValue)_color1"]?.pt_argbColor
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
    
    // 蒙版
    lazy var maskView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = .tertiaryLabel
        maskView.alpha = 0.7
        maskView.isHidden = true
        return maskView
    }()
    
    // 语音回答按钮
    lazy var poemAnswerSoundButton: PoetRecordButton = {
        let poemAnswerSoundButton = PoetRecordButton()
        poemAnswerSoundButton.setImage(UIImage(named: "poetic_time_poet_record_\(currentDynasty.rawValue)_image"), for: .normal)
        poemAnswerSoundButton.isEnabled = false
        poemAnswerSoundButton.moveCompletion = moveHandle
        poemAnswerSoundButton.setTitleColor(.black, for: .normal)
        poemAnswerSoundButton.titleLabel?.font = .boldSystemFont(ofSize: 24)
        // 去掉按钮原生的点击变暗效果
        poemAnswerSoundButton.adjustsImageWhenHighlighted = false
        poemAnswerSoundButton.addTarget(self, action: #selector(touchDownHandle), for: .touchDown)
        poemAnswerSoundButton.addTarget(self, action: #selector(touchUpInsideHandle), for: .touchUpInside)
        poemAnswerSoundButton.addTarget(self, action: #selector(touchUpOutsideHandle), for: .touchUpOutside)
        return poemAnswerSoundButton
    }()
    
    // 回答结果View
    lazy var checkLabel: UILabel = {
        let checkLabel = UILabel()
        checkLabel.font = .boldSystemFont(ofSize: 20)
        checkLabel.textColor = .red
        checkLabel.textAlignment = .center
        checkLabel.backgroundColor = .white
        checkLabel.layer.masksToBounds = true
        checkLabel.layer.cornerRadius = 20
        checkLabel.isHidden = true
        return checkLabel
    }()
    
    // 回答完成View
    lazy var finishView: UIView = {
        let finishView = UIView(frame: viewInitRect)
        finishView.backgroundColor = .white
        finishView.isHidden = true
        finishView.layer.masksToBounds = true
        finishView.layer.cornerRadius = 20
        return finishView
    }()
    
    // 回答完成View上的贴图
    lazy var finishImageView: UIImageView = {
        let finishImageView = UIImageView(frame: viewInitRect)
        finishImageView.image = UIImage(named: "poetic_time_poet_finish_view_image")
        return finishImageView
    }()
    
    // 回答完成View上的文本
    lazy var finishViewLabel: UILabel = {
        let finishViewLabel = UILabel()
        finishViewLabel.numberOfLines = 0
        finishViewLabel.lineBreakMode = .byWordWrapping // 按单词换行
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // 调整行间距
        var content = "诗才卓越\n本次答对\(answerNeedRightCount)题"
        // 整体样式
        var customAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: "#969696".pt_argbColor ?? .black
        ]
        
        var attributedString = NSMutableAttributedString(string: content, attributes: customAttributes)
        let range = NSMakeRange(0, content.count)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        if let range = content.range(of: String("\(answerNeedRightCount)")) {
            let nsRange = NSRange(range, in: content)
            // 部分样式
            let customSubAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: "#FF0000".pt_argbColor ?? .red // 自定义部分颜色
            ]
            attributedString.addAttributes(customSubAttributes, range: nsRange)
        }
        
        if let range = content.range(of: String("诗才卓越")) {
            let nsRange = NSRange(range, in: content)
            // 部分样式
            let customSubAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.black
            ]
            attributedString.addAttributes(customSubAttributes, range: nsRange)
        }
        
        finishViewLabel.attributedText = attributedString
        finishViewLabel.sizeToFit()
        return finishViewLabel
    }()
    
    // 继续挑战按钮
    lazy var continueButton: UIButton = {
        let continueButton = UIButton()
        continueButton.backgroundColor = "#5E918E".pt_argbColor ?? .systemPink
        continueButton.setTitle("继续挑战", for: .normal)
        continueButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 18
        continueButton.addTarget(self, action: #selector(continueHandle), for: .touchUpInside)
        return continueButton
    }()
    
    // 结束挑战按钮
    lazy var exitButton: UIButton = {
        let exitButton = UIButton()
        exitButton.backgroundColor = "#C3D9D7".pt_argbColor ?? .systemGray
        exitButton.setTitle("结束挑战", for: .normal)
        exitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.layer.cornerRadius = 18
        exitButton.addTarget(self, action: #selector(exitHandle), for: .touchUpInside)
        return exitButton
    }()
    
    lazy var stackButtonView: UIStackView = {
        let stackButtonView = UIStackView()
        stackButtonView.axis = .horizontal
        stackButtonView.spacing = 7
        stackButtonView.addArrangedSubview(exitButton)
        stackButtonView.addArrangedSubview(continueButton)
        return stackButtonView
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
        playPoetSound()
        // 判断网络状况
        if !isReachable {
            // 回主线程操作
            OperationQueue.main.addOperation { [weak self] in
                guard let self = self else { return }
                self.poemAnswerSoundButton.setImage(UIImage(named: "poetic_time_poet_rocord_net_error_\(currentDynasty.rawValue)_image"), for: .normal)
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
                    
                case .denied, .restricted, .notDetermined:
                    self.poemAnswerSoundButton.isEnabled = false
                    self.poemAnswerSoundButton.setImage(UIImage(named: "poetic_time_poet_rocord_net_error_\(currentDynasty.rawValue)_image"), for: .disabled)
                    
                default:
                    self.poemAnswerSoundButton.isEnabled = false
                }
            }
        }
    }
}
