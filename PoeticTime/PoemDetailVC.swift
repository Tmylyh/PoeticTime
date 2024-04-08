//
//  PoemDetailVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/2.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

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
    
    // 背景图
    lazy var backGroundImageView: UIImageView = {
        let backGroundImageView = UIImageView(frame: viewInitRect)
        backGroundImageView.image = UIImage(named: "poetic_time_poem_detail_back_ground_image")
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
        vrButton.addTarget(self, action: #selector(changeStarState), for: .touchUpInside)
        return vrButton
    }()
    
    // 诗名label
    lazy var poemNameLabel: UILabel = {
        let poemNameLabel = UILabel()
        poemNameLabel.text = "《\(poemName)》"
        poemNameLabel.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 24)
        poemNameLabel.textColor = "#048077".pt_argbColor
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

    // 请求音频文件
    func requestAudio() {
        debugPrint("\(audioURL)/\(AudioType.text.rawValue)/\(poemId)")
        AF.request("\(audioURL)/\(AudioType.text.rawValue)/\(poemId)").response { response in
            // 打印得到的数据
            debugPrint(String(data: response.data ?? Data(), encoding: .utf8)!)
            if let data = response.data {
                // 使用 SwiftyJSON 解析 Data 数据
                let json = try? JSON(data: data)

                // 检查解析是否成功
                if let json = json {
                    // 访问解析后的 JSON 数据
                    let audioURL = json["data", "audio"].stringValue
                    debugPrint("音频文件的URL:\(audioURL)")
                    guard let url = URL(string: audioURL) else { return }
                    self.downloadWavFile(from: url, poemId: self.poemId) { fileURL, error in
                        if let fileURL = fileURL {
                            // 下载成功，可以使用 fileURL 来访问临时文件
                            debugPrint("临时音频文件保存在：\(fileURL.path)")
                            // 配制播放器
                            self.setupAudioPlayer()
                        } else if let error = error {
                            // 下载失败，处理错误
                            debugPrint("下载失败，错误信息：\(error.localizedDescription)")
                        }
                    }
                } else {
                    debugPrint("解析 JSON 数据失败")
                    return
                }
            }
        }
    }

    // 下载音频文件
    func downloadWavFile(from url: URL, poemId: String, completion: @escaping (URL?, Error?) -> Void) {
        let destination: DownloadRequest.Destination = { _, _ in
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("audio\(poemId).wav")
            // .removePreviousFile：如果目标文件已经存在，先删除之前的文件。
            // .createIntermediateDirectories：如果需要，创建目标路径中缺失的文件夹。
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        AF.download(url, to: destination).responseData { response in
            switch response.result {
            case .success(_):
                // 下载成功，返回临时文件的 URL
                completion(response.fileURL, nil)
            case .failure(let error):
                // 下载失败，返回错误信息
                completion(nil, error)
            }
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

    // dimiss当前View
    @objc func dismissCurrentVC() {
        hero.dismissViewController()
        audioPlayer?.stop()
    }









    // 翻译后的文本
    var translateText = ""

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: Bounds)
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let audioFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("audio_text.wav")

    func playAudio() {
        do {
            // 创建 AVAudioPlayer 实例
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            // 准备播放
            audioPlayer?.prepareToPlay()
            // 播放音频
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }


    // 文生图
    func requestText2Image() {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = tempDirectoryURL.appendingPathComponent("example.txt")
        print(fileURL)
        let parameters: [String: Any] = [
                "denoising_strength": 0,
                "prompt": translateText + ",(masterpiece:1.2),best quality,highres,original,extremely detailed wallpaper,drawing,paintbrush",
                "negative_prompt": "(worst quality:2),(low quality:2),(normal quality:2),lowres,normal quality,",
                "seed": -1,
                "batch_size": 1,
                "n_iter": 1,
                "steps": 25,
                "cfg_scale": 7,
                "width": 720,
                "height": 1280,
                "restore_faces": false,
                "tiling": false,
                "override_settings": [
                    "sd_model_checkpoint": "4Guofeng4XL_v12.safetensors [9748eda16e]"
                ],
                "script_args": [],
                "sampler_index": "Euler" //采样方法
            ]
        AF.request("http://63234a3b.r12.cpolar.top/sdapi/v1/txt2img", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                try? data.write(to: fileURL)
                // 打印得到的数据
                debugPrint(String(data: data , encoding: .utf8)!)
                    // 使用 SwiftyJSON 解析 Data 数据
                    let json = try? JSON(data: data)

                    // 获取 images 数组
                    if let json = json, let imagesArray = json["images"].array {
                        // 获取第一个图片的 Base64 字符串
                        if let firstImageBase64 = imagesArray.first?.string {
                            // 将 Base64 字符串解码成图片数据
                            if let imageData = Data(base64Encoded: firstImageBase64) {
                                // 使用 imageData 进行后续操作，比如显示图片等
                                DispatchQueue.main.async {
                                    self.imageView.image = UIImage(data: imageData)
                                }
                                print("First image data:", imageData)
                            } else {
                                print("Failed to decode base64 string")
                            }
                        } else {
                            print("No images found")
                        }
                    } else {
                        print("No images array found")
                    }

            case .failure(let error):
                print("POST 请求失败：\(error)")
                // 在这里处理失败的情况
            }

        }
    }

    // 网络请求
    func requestPoetAnswer() {
        // 1. 准备请求的 URL
        guard let url = URL(string: "\(chatURL)/chat/chat") else {
            return
        }

        // 2. 准备请求体数据
        let parameters: [String: Any] = ["query": "白日依山尽，黄河入海流",
                          "conversation_id": "",
                          "history_len": -1,
                          "history": [],
                          "stream": false,
                          "model_name": "qwen-api",
                          "temperature": 0.7,
                          "max_tokens": 0,
                          "prompt_name": "translate"]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            debugPrint("Failed to serialize JSON data")
            return
        }

        // 3. 准备请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        // 4. 发送请求
        let task = URLSession.shared.dataTask(with: request) { [weak self] (result, response, error) in
            // 处理响应
            guard let result = result, let self = self, error == nil else {
                debugPrint("Error: \(error?.localizedDescription ?? "未知错误")")
                return
            }

            // data数据处理
            let courseJSONDatas = self.dataHandle(result: result)
            // 处理一个返回多个json的情况
            for courseJSONData in courseJSONDatas {
                // 排除ping的情况
                if !String(data: courseJSONData, encoding: .utf8)!.contains("ping") {
                    var resultText = ""
                    // 解析 JSON 数据
                    // 使用 SwiftyJSON 解析 Data 数据
                    let json = try? JSON(data: courseJSONData)

                    // 检查解析是否成功
                    if let json = json {
                        // 访问解析后的 JSON 数据
                        let text = json["text"].stringValue
                        let message_id = json["message_id"].stringValue
                        resultText = text.replacingOccurrences(of: kReturnKey, with: "")
                        resultText = text.replacingOccurrences(of: "\n", with: "")
                        self.translateText = resultText
                        print(resultText)
                        self.requestText2Image()
                    } else {
                        debugPrint("解析 JSON 数据失败")
                    }

                }
            }
        }
        // 启动请求任务
        task.resume()
    }

    // 数据处理
    func dataHandle(result: Data) -> [Data] {
        var result2Strings: [String] = []
        var courseJSONDatas: [Data] = []
        // 将结果转string进行处理
        guard let tmp = String(data: result, encoding: .utf8) else { return [] }
        let replacedStr = tmp.replacingOccurrences(of: "data: ", with: "=")
        result2Strings = replacedStr.components(separatedBy: "=")
        for i in result2Strings {
            var result2String = i
            // 取最后一个右大括号之前的内容
            if let range = result2String.range(of: "}", options: .backwards) {
                result2String = String(result2String[...range.lowerBound])
            }

            // 取第一个左大括号之后的内容
            if let range = result2String.range(of: "{") {
                result2String = String(result2String[range.lowerBound...])
            }

            // 得到替换回车后的字符串
            var newComment = result2String.replacingOccurrences(of: "\\n", with: kReturnKey)

            newComment = result2String.replacingOccurrences(of: "\n", with: kReturnKey)

            // 得到替换回退后的字符串
            newComment = result2String.replacingOccurrences(of: "\r", with: kBackKey)
            debugPrint(newComment)

            // 待解析的data
            let courseJSONData = newComment.data(using: .utf8)!
            courseJSONDatas.append(courseJSONData)
        }
        return courseJSONDatas
    }


    // let jsonFileName = "response2" // JSON 文件名
//    let jsonFileData = readJSONFromFile(fileName: jsonFileName) ?? Data() // 读取 JSON 文件数据
//    let imageData = Data(base64Encoded: jsonFileData)
//    imageView.image = UIImage(data: imageData!)

    // 从 JSON 文件中读取数据
    func readJSONFromFile(fileName: String) -> Data? {

        guard let rtfURL = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
            debugPrint("dynasty.rtf file not found")
            return Data()
        }
        do {
            let data = try Data(contentsOf: rtfURL)
                return data
            } catch {
                print("Error reading JSON file:", error)
            }
        return nil
    }

    // 解码 base64 编码的图像数据并保存为图片
    func decodeImageFromJSON(jsonData: Data, outputPath: String) {
        do {
            // 解析 JSON 数据
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let jsonDict = jsonObject as? [String: Any],
                  let imageDataString = jsonDict["image_data"] as? String,
                  let imageData = Data(base64Encoded: imageDataString) else {
                print("Invalid JSON format or missing image data")
                return
            }

            // 将图像数据解码为 UIImage
            guard let image = UIImage(data: imageData) else {
                print("Failed to decode image from base64 data")
                return
            }

            imageView.image = image

            // 将 UIImage 保存为图片文件
//            if let jpgData = image.jpegData(compressionQuality: 1.0) {
//                try jpgData.write(to: URL(fileURLWithPath: outputPath))
//                print("Image decoded successfully and saved to:", outputPath)
//            } else {
//                print("Failed to convert image to JPEG format")
//            }
        } catch {
            print("Error decoding JSON:", error)
        }
    }

    // 请求具体文本音频
    func requestTextAudio() {
        let parameters: [String: Any] = [
                "poet_id": "libai",
                "text": "张海森有病？"
            ]
        AF.request("http://6f56f1ef.r16.cpolar.top/verse", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { response in
                switch response.result {
                case .success(let data):
                    // 保存音频文件到临时文件夹
                    let tempDirectoryURL = FileManager.default.temporaryDirectory
                    let audioFileURL = tempDirectoryURL.appendingPathComponent("audio_file2.wav")

                    do {
                        try data.write(to: audioFileURL)
                        debugPrint("音频文件保存成功：\(audioFileURL.absoluteString)")
                    } catch {
                        debugPrint("保存音频文件失败：\(error)")
                    }

                case .failure(let error):
                    debugPrint("POST 请求失败：\(error)")
                    // 在这里处理失败的情况
                }
            }
    }
}
