//
//  PtARMenuVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/9.
//
import UIKit
import ARKit
import SnapKit

class PtARMenuVC: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    var arView: ARSCNView!
    var scnScene: SCNScene!
    
    var timer: Timer?
    var countdownSeconds = 60
    
    var qiang1Modal: SCNNode?
    var qiang2Modal: SCNNode?
    var qiang3Modal: SCNNode?
    var jin1Modal: SCNNode?
    var jin2Modal: SCNNode?
    var jiu1Modal: SCNNode?
    var jiu2Modal: SCNNode?
        
    lazy var imageView1: UIImageView = {
        let imageView = UIImageView(frame: viewInitRect)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    lazy var imageView2: UIImageView = {
        let imageView = UIImageView(frame: viewInitRect)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    lazy var imageView3: UIImageView = {
        let imageView = UIImageView(frame: viewInitRect)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private lazy var stackImageView: UIStackView = {
        let stackImageView = UIStackView()
        stackImageView.axis = .horizontal
        stackImageView.isHidden = true
        stackImageView.spacing = 10
        stackImageView.addArrangedSubview(imageView1)
        stackImageView.addArrangedSubview(imageView2)
        stackImageView.addArrangedSubview(imageView3)
        stackImageView.isUserInteractionEnabled = true
        return stackImageView
    }()
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.isHidden = true
        backButton.setImage(UIImage(named: "poetic_time_back_image"), for: .normal)
        backButton.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(dismissCurrentVC), for: .touchUpInside)
        return backButton
    }()
    
    // 倒计时
    let countdownLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 做题
    lazy var questionView: answerView = {
        let questionView = answerView()
        questionView.backgroundColor = .white
        questionView.isHidden = true
        questionView.completion = invalidateResult
        return questionView
    }()
    
    // 创建图标配置
    let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 30) // 指定图标大小为 30
    
    // 暂停按钮
    lazy var stopButton: UIButton = {
        let stopButton = UIButton()
        stopButton.setImage(UIImage(systemName: "pause.circle", withConfiguration: imageConfiguration), for: .normal)
        stopButton.isHidden = true
        stopButton.addTarget(self, action: #selector(pauseTime), for: .touchUpInside)
        return stopButton
    }()
    
    // 游戏结束的弹出View
    lazy var finishAlertView: PtAlertView = {
        let finishAlertView = PtAlertView(frame: viewInitRect)
        finishAlertView.backgroundColor = .white
        finishAlertView.isHidden = true
        finishAlertView.layer.cornerRadius = 20
        finishAlertView.layer.borderColor = UIColor.black.cgColor
        finishAlertView.layer.borderWidth = 2
        finishAlertView.alertText = "挑战成功"
        finishAlertView.cancelText = "取消"
        finishAlertView.confirmText = "退出"
        finishAlertView.cancelHandle = cancelHandle
        finishAlertView.confirmHandle = confirmHandle
        return finishAlertView
    }()
    
    // 配制UI
    func setARViewUI() {
        // 创建ARView
        arView = ARSCNView(frame: view.bounds)
        arView.delegate = self
        arView.session.delegate = self
        view.addSubview(arView)
        
        view.addSubview(stackImageView)
        view.addSubview(backButton)
        view.addSubview(questionView)
        view.addSubview(finishAlertView)
        view.addSubview(countdownLabel)
        view.addSubview(stopButton)
        
        imageView1.snp.makeConstraints { make in
            make.width.equalTo(90)
        }
        
        imageView2.snp.makeConstraints { make in
            make.width.equalTo(imageView1.snp.width)
        }
        
        imageView3.snp.makeConstraints { make in
            make.width.equalTo(imageView1.snp.width)
        }
        
        stackImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(44)
            make.height.equalTo(60)
            make.width.equalTo(220)
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(44)
            make.width.height.equalTo(32)
        }
        
        countdownLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stackImageView.snp.bottom).offset(16)
            make.width.height.equalTo(44)
        }
        
        questionView.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(200)
        }
        
        finishAlertView.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.height.equalTo(200)
            make.width.equalTo(250)
        }
        
        stopButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-ptTabBarHeight)
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setARViewUI()
        resetInit()
        
        // 添加点击事件
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
    }
       
    // 点击屏幕
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let tapLocation = gestureRecognizer.location(in: arView)
        let hitTestResults = arView.hitTest(tapLocation, options: [:])
        
        if let node = hitTestResults.first?.node {
            if node.name! == "modal1" {
                modalSelect1()
            } else if node.name! == "modal2" {
                modalSelect2()
            } else if node.name! == "bed" || node.name! == "money" || node.name! == "moon" {
                playModal2(name: node.name!, node: node)
            } else if node.name! == "exit" {
                dismiss(animated: true)
            }
        }
    }
    
    // 回到初始化场景
    @objc func dismissCurrentVC() {
        self.removeAllModels()
        self.resetInit()
    }
    
    // 初始化场景
    func resetInit() {
        scnScene = SCNScene(named: "art.scnassets/CubeScene.scn") // 加载 .scn 场景文件
        arView.scene = scnScene
        stackImageView.isHidden = true
        backButton.isHidden = true
        finishAlertView.isHidden = true
        questionView.isHidden = true
        countdownLabel.isHidden = true
        stopButton.isHidden = true
    }
    
    
    // 模式1被选择
    func modalSelect1() {
        placeModal1()
        backButton.isHidden = false
        // 开始倒计时
        countdownSeconds = 20
        countdownLabel.isHidden = false
        stopButton.isHidden = false
        stopCountdown()
        startCountdown()
    }
    
    // 模式2被选择
    func modalSelect2() {
        placeModal2()
        stackImageView.isHidden = false
        backButton.isHidden = false
        // 开始倒计时
        countdownSeconds = 60
        countdownLabel.isHidden = false
        stopCountdown()
        startCountdown()
    }
    
    // 暂停
    @objc func pauseTime() {
        timer?.invalidate()
        stopButton.isHidden = true
        questionView.isHidden = false
        hideModal1()
    }
    
    // 隐藏modal1模型
    func hideModal1() {
        qiang1Modal?.isHidden.toggle()
        qiang2Modal?.isHidden.toggle()
        qiang3Modal?.isHidden.toggle()
        jin1Modal?.isHidden.toggle()
        jin2Modal?.isHidden.toggle()
        jiu1Modal?.isHidden.toggle()
        jiu2Modal?.isHidden.toggle()
    }
    
    // 完成游戏一执行动画
    func finishModal1() {
        hideModal1()
        var translationAction = SCNAction.move(by: SCNVector3(-2, 0.0, -2), duration: 2)
        qiang1Modal!.runAction(translationAction)

        translationAction = SCNAction.move(by: SCNVector3(-1, 1, 0.0), duration: 2)
        qiang2Modal!.runAction(translationAction)
        
        translationAction = SCNAction.move(by: SCNVector3(1, 0.0, 0.0), duration: 2)
        qiang3Modal!.runAction(translationAction)
    
        translationAction = SCNAction.move(by: SCNVector3(-1, -1, 0.0), duration: 2)
        jin1Modal!.runAction(translationAction)
    
        translationAction = SCNAction.move(by: SCNVector3(2, 0.0, -1), duration: 2)
        // 将旋转动作应用到模型节点上，使其自传
        jin2Modal!.runAction(translationAction)

        translationAction = SCNAction.move(by: SCNVector3(-2, 0.0, -0.5), duration: 2)
        jiu1Modal!.runAction(translationAction)

        translationAction = SCNAction.move(by: SCNVector3(2, -2, -0.5), duration: 2)
        jiu2Modal!.runAction(translationAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.finishAlertView.isHidden = false
        }
    }
    
    // 玩游戏二中
    func playModal2(name: String, node: SCNNode) {
        node.removeFromParentNode()
        if name == "bed" {
            imageView1.image = UIImage(named: name)
        } else if name == "money" {
            imageView2.image = UIImage(named: name)
        } else {
            imageView3.image = UIImage(named: name)
        }
        if imageView1.image != nil && imageView2.image != nil && imageView3.image != nil {
            questionView.isHidden = false
        }
    }
    
    // 验证游戏结果
    func invalidateResult(answer: String) {
        questionView.isHidden = true
        if answer == "床前明月光" && countdownSeconds > 0 {
            finishAlertView.alertText = "挑战成功"
            finishAlertView.updateAlertUI()
            finishAlertView.isHidden = false
        } else if answer == "将进酒"  && countdownSeconds > 0 {
            finishAlertView.alertText = "挑战成功"
            finishAlertView.updateAlertUI()
            finishModal1()
        } else {
            weightFeedBack()
            if countdownSeconds <= 0 {
                finishAlertView.alertText = "挑战失败，超时"
            } else {
                finishAlertView.alertText = "挑战失败，答案错误"
            }
            finishAlertView.updateAlertUI()
            finishAlertView.isHidden = false
        }
    }
    
    // 游戏结束取消按钮
    func cancelHandle() {
        finishAlertView.isHidden = true
        questionView.isHidden = true
        countdownLabel.isHidden = true
        stopButton.isHidden = true
    }
    
    // 游戏结束确认按钮
    func confirmHandle() {
        dismissCurrentVC()
    }
    
    // 情况模型
    func removeAllModels() {
        // 遍历场景的所有节点，并删除它们
        for node in scnScene.rootNode.childNodes {
            node.removeFromParentNode()
        }
        imageView1.image = nil
        imageView2.image = nil
        imageView3.image = nil
    }
    
    // 放置模型1
    func placeModal1() {
        removeAllModels()
        // 加载模型文件
        guard let modelScene = SCNScene(named: "art.scnassets/textPlace.scn") else {
            fatalError("Failed to load model scene")
        }

        // 创建一个节点，并将加载的模型文件设置为节点的几何体
        let modelNode = SCNNode()
        for childNode in modelScene.rootNode.childNodes {
            if childNode.name == "qiang1" {
                qiang1Modal = childNode
                // 创建平移动画，将节点向后移动一个单位
                let translationAction = SCNAction.move(by: SCNVector3(2, 0.0, 2), duration: 0)
                // 将旋转动作应用到模型节点上，使其自传
                childNode.runAction(translationAction)
            } else if childNode.name == "qiang2" {
                qiang2Modal = childNode
                // 创建平移动画，将节点向后移动一个单位
                let translationAction = SCNAction.move(by: SCNVector3(1, -1, 0.0), duration: 0)
                // 将旋转动作应用到模型节点上，使其自传
                childNode.runAction(translationAction)
            } else if childNode.name == "qiang3" {
                qiang3Modal = childNode
                // 创建平移动画，将节点向后移动一个单位
                let translationAction = SCNAction.move(by: SCNVector3(-1, 0.0, 0.0), duration: 0)
                // 将旋转动作应用到模型节点上，使其自传
                childNode.runAction(translationAction)
            } else if childNode.name == "jin1" {
                jin1Modal = childNode
                // 创建平移动画，将节点向后移动一个单位
                let translationAction = SCNAction.move(by: SCNVector3(1, 1, 0.0), duration: 0)
                // 将旋转动作应用到模型节点上，使其自传
                childNode.runAction(translationAction)
            } else if childNode.name == "jin2" {
                jin2Modal = childNode
                // 创建平移动画，将节点向后移动一个单位
                let translationAction = SCNAction.move(by: SCNVector3(-2, 0.0, 1), duration: 0)
                // 将旋转动作应用到模型节点上，使其自传
                childNode.runAction(translationAction)
            } else if childNode.name == "jiu1" {
                jiu1Modal = childNode
                // 创建平移动画，将节点向后移动一个单位
                let translationAction = SCNAction.move(by: SCNVector3(2, 0.0, 0.5), duration: 0)
                // 将旋转动作应用到模型节点上，使其自传
                childNode.runAction(translationAction)
            } else if childNode.name == "jiu2" {
                jiu2Modal = childNode
                // 创建平移动画，将节点向后移动一个单位
                let translationAction = SCNAction.move(by: SCNVector3(-2, 2, 0.5), duration: 0)
                // 将旋转动作应用到模型节点上，使其自传
                childNode.runAction(translationAction)
            }
            modelNode.addChildNode(childNode)
        }

        // 将模型节点添加到场景中
        scnScene.rootNode.addChildNode(modelNode)
    }
    
    // 放置模型2
    func placeModal2() {
        removeAllModels()
        // 加载模型文件
        guard let modelScene = SCNScene(named: "art.scnassets/grassGround.scn") else {
            fatalError("Failed to load model scene")
        }

        // 创建一个节点，并将加载的模型文件设置为节点的几何体
        let modelNode = SCNNode()
        for childNode in modelScene.rootNode.childNodes {
            if childNode.name == "moon" {
                // 创建一个旋转动作
                let rotateAction = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 2) // 绕 Y 轴旋转180度，持续2秒
                let repeatAction = SCNAction.repeatForever(rotateAction) // 使动作无限循环
                
                // 将旋转动作应用到模型节点上，使其自传
                childNode.runAction(repeatAction)
            }
            modelNode.addChildNode(childNode)
        }

        // 设置模型节点的位置和旋转等属性
        modelNode.position = SCNVector3(x: 0, y: -4, z: -4) // 例如设置位置在场景的 (-2, 0, 0) 处
        modelNode.eulerAngles = SCNVector3(x: 0, y: 0, z: 0) // 设置旋转角度

        // 将模型节点添加到场景中
        scnScene.rootNode.addChildNode(modelNode)
    }
    
    // 开始计时
    func startCountdown() {
        // 每秒更新倒计时文本
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdownSeconds > 0 {
                self.countdownSeconds -= 1
                self.countdownLabel.text = "\(self.countdownSeconds)"
            } else {
                self.stopCountdown()
            }
        }
    }
    
    //停止计时
    func stopCountdown() {
        timer?.invalidate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
}
