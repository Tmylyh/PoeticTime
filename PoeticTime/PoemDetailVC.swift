//
//  PoemDetailVC.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/2.
//

import UIKit
import Alamofire
import SwiftyJSON

class PoemDetailVC: UIViewController {
    
    let poemId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
    }
    
    // 请求音频文件
    func requestAudio() {
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
                    let url = URL(string: audioURL)! // 替换为实际的 WAV 文件 URL
                    self.downloadWavFile(from: url, poemId: self.poemId) { fileURL, error in
                        if let fileURL = fileURL {
                            // 下载成功，可以使用 fileURL 来访问临时文件
                            debugPrint("临时音频文件保存在：\(fileURL.path)")
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

}
