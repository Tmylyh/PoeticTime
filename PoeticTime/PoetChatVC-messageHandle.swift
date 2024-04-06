//
//  PoetChatVC-messageHandle.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/2.
//

import UIKit
import MessageKit
import SwiftyJSON
import Alamofire

extension PoetChatVC: MessagesDataSource, MessagesLayoutDelegate {
    // 结构体用于解析 JSON 响应
    struct Response: Codable {
        let text: String
        let message_id: String
    }
    
    // 结构体用于发请求
    struct PostParameter: Codable {
        let query: String
        let conversation_id: String
        let history_len: Int
        let history: [String]
        let stream: Bool
        let model_name: String
        let temperature: Double
        let max_tokens: Int
        let prompt_name: String
    }
    
    // 网络流请求
    func requestStreamPoetAnswer() {
        // 1. 准备请求的 URL
        guard let url = URL(string: "\(chatURL)/chat/poet") else {
            return
        }
        
        let postParameter = PostParameter(query: currentMessage,
                                          conversation_id: "",
                                          history_len: -1,
                                          history: [],
                                          stream: true,
                                          model_name: "qwen-api",
                                          temperature: 0.7,
                                          max_tokens: 0,
                                          prompt_name: poetId)
        
        request = AF.streamRequest(url,
                         method: .post,
                         parameters: postParameter,
                         encoder: JSONParameterEncoder.default).responseStream { [weak self] stream in
            guard let self = self else { return }
            var resultText = ""
            var resultMessage_id = ""
            switch stream.event {
                case let .stream(result):
                    switch result {
                    case let .success(data):
                        debugPrint(data)
                        // 数据处理
                        var courseJSONDatas = self.dataHandle(result: data)
                        if !courseJSONDatas.isEmpty {
                            if courseJSONDatas.first!.count == 0 {
                                courseJSONDatas.removeFirst()
                            }
                        }
                        // 处理一个返回多个json的情况
                        for courseJSONData in courseJSONDatas {
                            // 排除ping的情况
                            if !String(data: courseJSONData, encoding: .utf8)!.contains("ping") {
                                // 使用 SwiftyJSON 解析 Data 数据
                                let json = try? JSON(data: courseJSONData)
                                
                                // 检查解析是否成功
                                if let json = json {
                                    // 访问解析后的 JSON 数据
                                    let text = json["text"].stringValue
                                    let message_id = json["message_id"].stringValue
                                    resultText = text.replacingOccurrences(of: kReturnKey, with: "\n")
                                    resultMessage_id = message_id.replacingOccurrences(of: kReturnKey, with: "\n")
                                } else {
                                    debugPrint("解析 JSON 数据失败")
                                    return
                                }
                                // 是否是同一个流
                                let isSameStream = resultMessage_id == self.currentPoetMessageid
                                
                                guard let poetUser = self.poetUser else { return }
                                // 如果是同一个流
                                if isSameStream {
                                    // 扩展消息
                                    self.currentAnswer.append(resultText)
                                    let message = Message(sender: poetUser, messageId: self.currentPoetMessageid, sentDate: Date(), kind: .text(self.currentAnswer))
                                    // 更新同一消息
                                    self.updateMessage(message)
                                } else {
                                    // 更新消息id
                                    self.currentPoetMessageid = resultMessage_id
                                    
                                    // 新增消息
                                    self.currentAnswer = resultText
                                    let message = Message(sender: poetUser, messageId: self.currentPoetMessageid, sentDate: Date(), kind: .text(self.currentAnswer))
                                    self.insertMessage(message)
                                }
                            }
                        }
                    }
                case let .complete(completion):
                    // 完成后可执行操作
                    debugPrint("当前流获取完毕\(completion)")
                }
        }
    }

    // 网络请求
    func requestPoetAnswer() {
        // 1. 准备请求的 URL
        guard let url = URL(string: "\(chatURL)/chat/poet") else {
            return
        }

        // 2. 准备请求体数据
        let parameters: [String: Any] = ["query": "\(currentMessage)",
                          "conversation_id": "",
                          "history_len": -1,
                          "history": [],
                          "stream": false,
                          "model_name": "qwen-api",
                          "temperature": 0.7,
                          "max_tokens": 0,
                          "prompt_name": "\(poetId)"]
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
            guard let self = self, let poetUser = self.poetUser else { return }
            // 处理响应
            guard let result = result, error == nil else {
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
                    var resultMessage_id = ""
                    // 解析 JSON 数据
                    // 使用 SwiftyJSON 解析 Data 数据
                    let json = try? JSON(data: courseJSONData)
                    
                    // 检查解析是否成功
                    if let json = json {
                        // 访问解析后的 JSON 数据
                        let text = json["text"].stringValue
                        let message_id = json["message_id"].stringValue
                        resultText = text.replacingOccurrences(of: kReturnKey, with: "\n")
                        resultMessage_id = message_id.replacingOccurrences(of: kReturnKey, with: "\n")
                    } else {
                        debugPrint("解析 JSON 数据失败")
                    }
                    
                    // 是否是同一个流
                    let isSameStream = resultMessage_id == self.currentPoetMessageid
                    
                    // 如果是同一个流
                    if isSameStream {
                        // 扩展消息
                        self.currentAnswer.append(resultText)
                        let message = Message(sender: poetUser, messageId: self.currentPoetMessageid, sentDate: Date(), kind: .text(self.currentAnswer))
                        // 更新同一消息
                        self.updateMessage(message)
                    } else {
                        // 更新消息id
                        self.currentPoetMessageid = resultMessage_id
                        
                        // 新增消息
                        self.currentAnswer = resultText
                        let message = Message(sender: poetUser, messageId: self.currentPoetMessageid, sentDate: Date(), kind: .text(self.currentAnswer))
                        self.insertMessage(message)
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
            var newComment = result2String.replacingOccurrences(of: "\n", with: kReturnKey)
            
            // 得到替换回退后的字符串
            newComment = result2String.replacingOccurrences(of: "\r", with: kBackKey)
            debugPrint(newComment)
            
            // 待解析的data
            let courseJSONData = newComment.data(using: .utf8)!
            courseJSONDatas.append(courseJSONData)
        }
        return courseJSONDatas
    }
    
    // 新增信息
    func insertMessage(_ message: Message) {
        // 加入数据源数组
        messages.append(message)
        
        if message.sender.senderId == currentUser.senderId && isReachable {
            requestStreamPoetAnswer()
        }
        // UI在主线程修改
        DispatchQueue.main.async {
            // 更新collectionView
            self.messagesCollectionView.performBatchUpdates({
                self.messagesCollectionView.insertSections([self.messages.count - 1])
                // 如果大于一条就说明目前已有信息，需要更新
                if self.messages.count >= 2 {
                    self.messagesCollectionView.reloadSections([self.messages.count - 2])
                }
            }, completion: { [weak self] _ in
                if self?.isLastSectionVisible() == true {
                    // 滑动到最新信息
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                }
            })
        }
    }
    
    // 更新某一条信息内容
    func updateMessage(_ updatedMessage: Message) {
        // 在 messages 数组中找到需要更新的消息
        if let index = messages.firstIndex(where: { $0.messageId == updatedMessage.messageId }) {
            // 更新消息内容
            messages[index] = updatedMessage
            
            // 溢出判断
            if index < messagesCollectionView.numberOfSections {
                // 刷新包含该消息的 section
                messagesCollectionView.reloadSections([index])
            }
        }
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    // 最后一条信息是否可见
    func isLastSectionVisible() -> Bool {
      guard !messages.isEmpty else { return false }

      let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)

      return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    // 设置cell的信息
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    // 返回几个cell
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension PoetChatVC: MessagesDisplayDelegate {
    // 设置头像
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let poetUser = poetUser else { return }
            // 根据消息的发送者设置头像
            switch message.sender.senderId {
            case currentUser.senderId:
                avatarView.image = UIImage(named: "poetic_time_poet_image")
            case poetUser.senderId:
                avatarView.image = UIImage(named: "poetic_time_poet_image_\(poetId)") ?? UIImage(named: "poetic_time_poet_image_dumu")
            default:
                break
            }

            // 设置头像的大小和圆角等属性
            avatarView.contentMode = .scaleAspectFill
            avatarView.layer.masksToBounds = true
            avatarView.layer.cornerRadius = 16 // 设置圆角半径，根据你的设计来调整
    }
}

