//
//  ScanVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/20.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ScanVC: UIViewController {
    
    lazy var rightBarButtonImageView: UIImageView = {
        let rightBarButtonImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        rightBarButtonImageView.image = .init(systemName: "camera")
        rightBarButtonImageView.contentMode = .scaleAspectFit
        rightBarButtonImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickHandler))
        rightBarButtonImageView.addGestureRecognizer(tap)
        return rightBarButtonImageView
    }()
    
    lazy var contentImageView: UIImageView = {
        let contentImageView = UIImageView(frame: viewInitRect)
        contentImageView.contentMode = .scaleAspectFit
        contentImageView.backgroundColor = .blue
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        return contentImageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBarButtonItem()
        setBaseUI()
    }
    
    // 配制view
    func setBaseUI() {
        view.addSubview(contentImageView)
        NSLayoutConstraint.activate([
            contentImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -88),
            contentImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 88)
        ])
    }
    
    // 配制最右上侧的item
    func setNavBarButtonItem() {
        let barButtonItem = UIBarButtonItem(customView: rightBarButtonImageView)
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func pickHandler() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
        TorchController().turnTorchOn()
    }

}

extension ScanVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            contentImageView.image = image
            navigationItem.title = "识别中..."
            
            guard let ciImage = CIImage(image: image) else{
                fatalError("不能把图像转化为CIImage")
            }
            
            // 调用你的机器识别函数进行物体检测
            //1.转化图像
            let defaultConfig = MLModelConfiguration()

            // Create an instance of the image classifier's wrapper class.
            let imageClassifierWrapper = try? MyImageClassifier(configuration: defaultConfig)

            guard let imageClassifier = imageClassifierWrapper else {
                fatalError("App failed to create an image classifier model instance.")
            }

            // 获取基础模型实例
            let imageClassifierModel = imageClassifier.model
            
            guard let model = try? VNCoreMLModel(for: imageClassifierModel) else{
                fatalError("加载model失败")
            }
            let request = VNCoreMLRequest(model: model) { (request, error) in
                
                guard let res = request.results else{
                    self.navigationItem.title = "图像识别失败"
                    return
                }
                
                let classifications = res as! [VNClassificationObservation]
                if classifications.isEmpty{
                    self.navigationItem.title = "不知道是什么..."
                }else{
                    self.navigationItem.title = classifications.first!.identifier
                }
                
            }
            request.imageCropAndScaleOption = .centerCrop
            
            do{
                try VNImageRequestHandler(ciImage: ciImage).perform([request])
            }catch{
                print("执行图像识别请求失败，原因是：\(error.localizedDescription)")
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

class TorchController {
    
    // 手电筒开关状态
    var isTorchOn: Bool {
        return torchMode == .on
    }
    
    // AVCaptureDevice 实例
    private let device = AVCaptureDevice.default(for: AVMediaType.video)
    
    // 手电筒模式
    private var torchMode: AVCaptureDevice.TorchMode {
        return device?.torchMode ?? .off
    }
    
    // 打开手电筒
    public func turnTorchOn() {
        guard let device = device else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = .on
            device.unlockForConfiguration()
        } catch {
            print("无法打开手电筒: \(error.localizedDescription)")
        }
    }
    
    // 关闭手电筒
    func turnTorchOff() {
        guard let device = device else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
        } catch {
            print("无法关闭手电筒: \(error.localizedDescription)")
        }
    }
}

