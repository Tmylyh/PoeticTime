//
//  PoemDetailVC-Request.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/10.
//

import UIKit
import MBProgressHUD
import Alamofire
import SwiftyJSON
import AVFoundation

extension PoemDetailVC {
    
    // MARK: - 音频
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
                    debugPrint("解析 音频文件JSON 数据失败")
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
    
    
    // MARK: - 文生图
    // 进度条增加
    @objc func stepAdd() {
        if processCount == 99 {
            timer1?.invalidate()
        } else {
            processCount += 1
            // 更新进度
            progress.completedUnitCount = Int64(processCount)
        }
    }
    
    // 发AI请求
    func requestAIImage(completion: @escaping () -> Void) -> Progress {
        
        timer1 = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(stepAdd), userInfo: nil, repeats: true)
        
        // 创建后台任务，防止用户切换到后台，导致连接中断
        var backgroundTask: UIBackgroundTaskIdentifier = .invalid
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            // 后台任务结束时执行清理操作
            completion()
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
        
        // 发起翻译请求
        requestEnglishTranslate {
            // 翻译请求完成后的处理
            // 结束后台任务
            UIApplication.shared.endBackgroundTask(backgroundTask)
            completion()
        }
        
        return progress
    }
    
    // 网络请求翻译
    func requestEnglishTranslate(completion: @escaping () -> Void) {
        // 1. 准备请求的 URL
        guard let url = URL(string: "\(chatURL)/chat/chat") else {
            return
        }
        
        // 2. 准备请求体数据
        let parameters: [String: Any] = ["query": "\(poemName)，\(poemBody)",
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
            let courseJSONDatas = dataHandle(result: result)
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
                        resultText = text.replacingOccurrences(of: kReturnKey, with: "")
                        resultText = text.replacingOccurrences(of: "\n", with: "")
                        self.translateText = resultText
                        // 打印翻译后的文本
                        debugPrint(resultText)
                        self.requestText2Image(completion: completion)
                    } else {
                        debugPrint("解析 翻译JSON 数据失败")
                    }
                }
            }
        }
        // 启动请求任务
        task.resume()
    }
    
    // 文生图请求
    func requestText2Image(completion: @escaping () -> Void) {
        
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = tempDirectoryURL.appendingPathComponent("\(poemId)Text2Image.txt")
        debugPrint(fileURL)
        let parameters: [String: Any] = [
            "denoising_strength": 0,
            "prompt": translateText + ",(masterpiece:1.2),best quality,highres,original,extremely detailed wallpaper,drawing,paintbrush",
            "negative_prompt": "(worst quality:2),(low quality:2),(normal quality:2),lowres,normal quality,",
            "seed": -1,
            "batch_size": 1,
            "n_iter": 1,
            "steps": 20,
            "cfg_scale": 7,
            "width": 1500,
            "height": 750,
            "restore_faces": false,
            "tiling": false,
            "override_settings": [
                "sd_model_checkpoint": "4Guofeng4XL_v12.safetensors [9748eda16e]"
            ],
            "script_args": [],
            "sampler_index": "Euler" //采样方法
        ]
        request = AF.request("\(panoramicImageURL)/sdapi/v1/txt2img", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { [weak self] response in
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
                                self.panoramicImage = UIImage(data: imageData)
                                self.progress.completedUnitCount = Int64(100)
                                // 任务完成时调用 completion
                                completion()
                            }
                            debugPrint("First image data:", imageData)
                        } else {
                            debugPrint("Failed to decode base64 string")
                        }
                    } else {
                        debugPrint("No images found")
                    }
                } else {
                    debugPrint("No images array found")
                }
                
            case .failure(let error):
                print("POST 请求失败：\(error)")
                // 在这里处理失败的情况
            }
        }
    }
}
