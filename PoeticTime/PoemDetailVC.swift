//
//  PoemDetailVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/2.
//

import UIKit
import AVFoundation
import Alamofire
import MBProgressHUD

class PoemDetailVC: UIViewController, AVAudioPlayerDelegate {
    
    // 创建图标配置
    let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 30) // 指定图标大小为 30
    
    // 诗词id
    var poemId: String = ""
    
    // 诗词名
    var poemName: String = ""
    
    // 诗词主体
    var poemBody: String = ""
    
    // 诗人id
    var poetId: String = ""
    
    // 诗人名
    var poetName: String = ""
    
    // 朝代id
    var dynastyId: String = ""
    
    // 朝代名
    var dynastyName: String = ""
    
    // 是否被收藏
    var isStar: Bool = false
    
    // 改变收藏状态需要执行的闭包
    var changeStarStatus: ((Bool) -> Void)?
    
    // 播放器
    var audioPlayer: AVAudioPlayer?
    
    // 计时器
    var timer: CADisplayLink?
    
    // 音频路径
    var fileURL = URL(string: "")
    
    // 计时器
    var timer1: Timer?
    
    // 翻译后的文本
    var translateText = ""
    
    // 进度条实例子
    let progress = Progress(totalUnitCount: 100)
    
    // 进度条进度
    var processCount = 0
    
    // 网络请求
    var request: DataRequest?
    
    // 全景图
    var panoramicImage: UIImage?
    
    // 背景图
    lazy var backGroundImageView: UIImageView = {
        let backGroundImageView = UIImageView(frame: viewInitRect)
        backGroundImageView.image = UIImage(named: "poetic_time_poem_detail_back_ground_\(currentDynasty.rawValue)_image")
        backGroundImageView.contentMode = .scaleAspectFill
        return backGroundImageView
    }()
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "poetic_time_back_image"), for: .normal)
        backButton.addTarget(self, action: #selector(dismissCurrentVC), for: .touchUpInside)
        return backButton
    }()
    
    // 收藏按钮
    lazy var starButton: UIButton = {
        let starButton = UIButton()
        starButton.backgroundColor = .clear
        starButton.imageView?.contentMode = .scaleAspectFill
        starButton.addTarget(self, action: #selector(changeStarState), for: .touchUpInside)
        return starButton
    }()
    
    // 问答按钮
    lazy var chatQuestionButton: UIButton = {
        let chatQuestionButton = UIButton()
        chatQuestionButton.backgroundColor = .clear
        chatQuestionButton.setImage(UIImage(named: "poetic_time_poem_detail_chat_question_image"), for: .normal)
        chatQuestionButton.imageView?.contentMode = .scaleAspectFill
        chatQuestionButton.addTarget(self, action: #selector(presentChatVC), for: .touchUpInside)
        return chatQuestionButton
    }()
    
    // VR按钮
    lazy var vrButton: UIButton = {
        let vrButton = UIButton()
        vrButton.backgroundColor = .clear
        vrButton.setImage(UIImage(named: "poetic_time_poem_detail_vr_image"), for: .normal)
        vrButton.imageView?.contentMode = .scaleAspectFit
        vrButton.addTarget(self, action: #selector(presentPanoramic), for: .touchUpInside)
        return vrButton
    }()
    
    // 诗名label
    lazy var poemNameLabel: UILabel = {
        let poemNameLabel = UILabel()
        poemNameLabel.text = "《\(poemName)》"
        poemNameLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 24)
        poemNameLabel.textColor = .black
        poemNameLabel.numberOfLines = 0
        poemNameLabel.textAlignment = .center
        return poemNameLabel
    }()
    
    // 诗人名和朝代label
    lazy var poetNameAndDynastyLabel: UILabel = {
        let poetNameAndDynastyLabel = UILabel()
        poetNameAndDynastyLabel.text = "\(poetName) [\(dynastyName)]"
        poetNameAndDynastyLabel.font = .systemFont(ofSize: 14)
        poetNameAndDynastyLabel.textColor = "#7D7D7D".pt_argbColor
        poetNameAndDynastyLabel.numberOfLines = 0
        poetNameAndDynastyLabel.textAlignment = .center
        return poetNameAndDynastyLabel
    }()
    
    // 诗文Label
    lazy var poemBodyTextView: UITextView = {
        let poemBodyTextView = UITextView()
        poemBodyTextView.backgroundColor = .clear
        poemBodyTextView.isEditable = false
        
        // 调整文本视图的行距
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10 // 设置行距
        paragraphStyle.alignment = .center // 设置文本对齐方式

        // 创建富文本
        let attributedString = NSMutableAttributedString(string: poemBody, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])

        // 添加字体、颜色和对齐方式到富文本中
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: ZiTi.sjbkjt.rawValue, size: 22) ?? UIFont.systemFont(ofSize: 22),
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
        ], range: NSRange(location: 0, length: attributedString.length))

        // 应用富文本到文本视图
        poemBodyTextView.attributedText = attributedString
        
        poemBodyTextView.showsVerticalScrollIndicator = false
        return poemBodyTextView
    }()
    
    // 播放暂停按钮
    lazy var playPauseButton: UIButton = {
        let button = UIButton()
        // 获取系统提供的图标
        let image = UIImage(systemName: "play.circle", withConfiguration: imageConfiguration)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .black
        button.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    // 进度条
    lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()

    // 当前时间标签
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0:00"
        return label
    }()

    // 总时长标签
    let durationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0:00"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        poemBody = addNewlineAfterEvenPunctuation(input: poemBody)
        setPoemDetailUI()
        // 初始化音频路径
        fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("audio\(poemId).wav")
        if !FileManager.default.fileExists(atPath: fileURL?.path ?? "") {
            requestAudio()
        } else {
            setupAudioPlayer()
        }
    }

    // 更新收藏状态
    @objc func changeStarState(sender: UIButton) {
        ButtonAnimate(sender)
        isStar.toggle()
        // 获取内存中对应数据的index
        let index = poemData.firstIndex { poem in
            poem.poemId == poemId
        }
        guard let index = index else { return }
        let poem = poemData.filter { $0.poemId == poemId }
        // 修改内存中数据
        poemData[index] = Poem(poemId: poem.first?.poemId ?? "", poemName: poem.first?.poemName ?? "", poetId: poem.first?.poetId ?? "", dynastyId: poem.first?.dynastyId ?? "", poemBody: poem.first?.poemBody ?? "", poemStar: !(poem.first?.poemStar ?? true))
        let star = poemData[index].poemStar ? "is" : "no"
        // 修改UI
        starButton.setImage(UIImage(named: "poetic_time_poem_card_\(star)_star_image"), for: .normal)
        // 存入数据库
        let info = DBInfo(poemId: poemData[index].poemId, poemName: poemData[index].poemName, poetId: poemData[index].poetId, dynastyId: poemData[index].dynastyId, poemBody: poemData[index].poemBody, poemStar: poemData[index].poemStar)
        PoeticTimeDao.updateElement(info: info)
        // 执行回调
        changeStarStatus?(isStar)
    }
    
    // 跳转到聊天
    @objc func presentChatVC(sender: UIButton) {
        ButtonAnimate(sender)
        sender.hero.id = "poetChat"
        let poet = poetData.filter { $0.poetName == poetName }
        guard let poetId = poet.first?.poetId else { return }
        let poetChatVC = PoetChatVC(poetId: poetId)
        poetChatVC.currentMessage = "你叫什么名字，简单说说你的\(poemName)的写作背景"
        poetChatVC.poetName = poetName
        poetChatVC.view.hero.id = "poetChat"
        poetChatVC.hero.isEnabled = true
        poetChatVC.heroModalAnimationType = .zoom
        poetChatVC.modalPresentationStyle = .fullScreen
        present(poetChatVC, animated: true)
    }
    
    // present到全景图
    @objc func presentPanoramic(sender: UIButton) {
        ButtonAnimate(sender)
        // 请求and进度条
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "生成图片中，请稍候"
        hud.label.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 16)
        let progress = self.requestAIImage {
            DispatchQueue.main.async {
                hud.hide(animated: true)
                let panoramicVC = PoemPanoramicVC()
                panoramicVC.panoramicImage = self.panoramicImage ?? UIImage()
                panoramicVC.modalPresentationStyle = .fullScreen
                self.present(panoramicVC, animated: true)
            }
        }
        hud.progressObject = progress
    }

    // dimiss当前View
    @objc func dismissCurrentVC() {
        hero.dismissViewController()
        audioPlayer?.stop()
        timer?.invalidate()
        timer1?.invalidate()
        request?.cancel()
    }
}
