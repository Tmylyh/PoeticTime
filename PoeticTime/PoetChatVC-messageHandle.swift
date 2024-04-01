//
//  PoetChatVC-messageHandle.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/2.
//

import UIKit
import MessageKit
import SwiftyJSON

extension PoetChatVC: MessagesDataSource, MessagesLayoutDelegate {
    // 结构体用于解析 JSON 响应
    struct Response: Codable {
        let text: String
        let message_id: String
    }
    
    // 网络请求
    func requestPoetAnswer() {
        // 1. 准备请求的 URL
        guard let url = URL(string: "http://7f5ca150.r8.cpolar.top/chat/poet") else {
            print("Invalid URL")
            return
        }

        // 2. 准备请求体数据
        let parameters: [String: Any] = ["query": "\(currentMessage)",
                          "conversation_id": "",
                          "history_len": -1,
                          "history": [],
                          "stream": true,
                          "model_name": "qwen-api",
                          "temperature": 0.7,
                          "max_tokens": 0,
                          "prompt_name": "\(poetId)"]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Failed to serialize JSON data")
            return
        }

        // 3. 准备请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        // 4. 发送请求
        let task = URLSession.shared.dataTask(with: request) { [weak self] (result, response, error) in
            guard let self = self else { return }
            // 处理响应
            guard let result = result, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            // 将结果转string进行处理
            guard let result2String = String(data: result, encoding: .utf8) else { return }
        
            // 将结果去掉前缀
            let splitString = String(result2String.dropFirst(6))
            debugPrint(splitString)
            
            // 自定义替换换行符的序列，防止换行符导致json解析不出来
            let kReturnKey = "abcdefg"

            // 得到替换后的字符串
            let newComment = splitString.replacingOccurrences(of: "\n", with: kReturnKey)

            // 待解析的data
            let courseJSONData = newComment.data(using: .utf8)!
            
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

        // 启动请求任务
        task.resume()
    }
    
    // 清理历史对话
    func clearRequest() {
        // 1. 准备请求的 URL
        guard let url = URL(string: "http://7f5ca150.r8.cpolar.top/chat/clear") else {
            print("Invalid URL")
            return
        }

        // 3. 准备请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 4. 发送请求
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
        }

        // 启动请求任务
        task.resume()
    }
    
    // 新增信息
    func insertMessage(_ message: Message) {
        // 加入数据源数组
        messages.append(message)
        
        if message.sender.senderId == currentUser.senderId && isReachable {
            requestPoetAnswer()
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
            
            // 刷新包含该消息的 section
            messagesCollectionView.reloadSections([index])
        }
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
                avatarView.image = UIImage(named: "poetic_time_poet_image")
            default:
                break
            }

            // 设置头像的大小和圆角等属性
            avatarView.contentMode = .scaleAspectFill
            avatarView.layer.masksToBounds = true
            avatarView.layer.cornerRadius = 16 // 设置圆角半径，根据你的设计来调整
    }
}

