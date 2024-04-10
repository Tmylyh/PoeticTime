//
//  PoemPanoramicVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/10.
//

import UIKit
import SceneKit
import CoreMotion
import SnapKit

class PoemPanoramicVC: UIViewController {

    var sceneView: SCNView!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    var motionManager: CMMotionManager!
    
    var panoramicImage: UIImage = UIImage()
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "poetic_time_back_image"), for: .normal)
        backButton.addTarget(self, action: #selector(dismissCurrentVC), for: .touchUpInside)
        return backButton
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        view.addSubview(sceneView)
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(44)
            make.height.width.equalTo(32)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
        // 开始渲染循环
        sceneView.isPlaying = true
        sceneView.prepare([scene!], completionHandler: { success in
            if success {
                self.sceneView.play(nil)
            } else {
                debugPrint("Failed to prepare the scene for playback.")
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNeedsStatusBarAppearanceUpdate()
        // 停止渲染循环
        sceneView.isPlaying = false
    }
    
    func config() {
        
        // 创建 SceneKit 视图
        sceneView = SCNView(frame: view.frame)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 创建场景
        scene = SCNScene()
        
        // 创建相机节点
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // 设置相机节点的位置和方向
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        cameraNode.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
        
        // 创建球体
        let sphere = SCNSphere(radius: 10)
        let originalImage = panoramicImage
        let resultImage = self.addBlackBorder(toImage: originalImage, widthBorderSize: 800, heightBorderSize: 400)
        sphere.firstMaterial?.diffuse.contents = resultImage
        sphere.firstMaterial?.isDoubleSided = false
        sphere.firstMaterial?.cullMode = .front//剔除正面
        let sphereNode = SCNNode(geometry: sphere)
        // 创建绕 Y 轴旋转 180 度的旋转矩阵
        let rotationMatrix = SCNMatrix4MakeRotation(.pi, 0, 1, 0)
        // 应用旋转矩阵到节点的变换中
        sphereNode.transform = rotationMatrix
        sphereNode.scale = SCNVector3(x: -1, y: 1, z: 1) // 反转球体的方向，使其正面朝内
        scene.rootNode.addChildNode(sphereNode)
        
        // 启动陀螺仪
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1 / 60 // 设置更新间隔
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            guard let motion = motion, error == nil else { return }
            
            let attitude = motion.attitude
            
            let quaternion = attitude.quaternion
            self.cameraNode.orientation = self.orientationFromCMQuaternion(quaternion: quaternion)
        }
        
        // 将场景设置为视图的场景
        sceneView.scene = scene
        // 允许用户控制相机
        sceneView.allowsCameraControl = false
        // 设置渲染质量
        sceneView.antialiasingMode = .multisampling4X
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 释放任何可以被重新创建的资源。
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 调整场景视图的大小和位置
        sceneView.frame = view.frame
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 停止陀螺仪更新
        motionManager.stopDeviceMotionUpdates()
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        // 摇晃设备时重新定位相机的方向
        cameraNode.eulerAngles = SCNVector3(x: 0, y: -Float(motionManager.deviceMotion!.attitude.yaw), z: 0)
    }
    
    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // 如果设备摇晃被取消，不执行任何操作
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // 如果设备停止摇晃，不执行任何操作
    }

    func orientationFromCMQuaternion(quaternion:CMQuaternion) -> SCNVector4 {
        let gq1 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-90), 1, 0, 0)
        let gq2 = GLKQuaternionMake(Float(quaternion.x), Float(quaternion.y), Float(quaternion.z), Float(quaternion.w))
        let qp = GLKQuaternionMultiply(gq1, gq2)
            return SCNVector4Make(qp.x, qp.y, qp.z, qp.w)
    }
    
    // dimiss当前View
    @objc func dismissCurrentVC() {
        self.dismiss(animated: true)
    }
    
    // 处理图片成全景图
    func addBlackBorder(toImage image: UIImage, widthBorderSize: CGFloat, heightBorderSize: CGFloat) -> UIImage {
        // 计算新图片的总大小
        let newSize = CGSize(width: image.size.width + widthBorderSize * 2, height: image.size.height + heightBorderSize * 2)
        
        // 开始一个新的绘制上下文
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        
        // 获取当前上下文
        guard let context = UIGraphicsGetCurrentContext() else {
            return image
        }
        
        // 设置背景颜色为黑色并填充整个上下文
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: newSize))
        
        // 计算原始图片在新图片中的位置，使其居中
        let xOffset = (newSize.width - image.size.width) / 2
        let yOffset = (newSize.height - image.size.height) / 2
        
        // 将原始图片绘制到上下文的正确位置
        image.draw(in: CGRect(x: xOffset, y: yOffset, width: image.size.width, height: image.size.height))
        
        // 从上下文中获取新图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 清理上下文并结束绘制
        UIGraphicsEndImageContext()
        
        // 返回新的带边框的图片
        return newImage ?? image
    }
}
