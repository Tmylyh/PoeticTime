//
//  PoetAnswerVC-logic.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/1.
//

import UIKit
import Alamofire
import AVFoundation

extension PoetAnswerVC: AVAudioPlayerDelegate {
    // 获取题目数据
    func getQuestionData() {
        // 定义分隔符集合
        let separators = CharacterSet(charactersIn: "，。？！；")
        // 拿到诗词数据
        let infoData = poemData.filter { $0.poetId == poetId }
        for info in infoData {
            var components = info.poemBody.components(separatedBy: separators)
            let poemName = info.poemName
            // 去掉最后一个空字符串
            components.removeLast()
            // 一首诗词对话
            var tmpPoemQuestion: [[String]] = []
            var i = 0
            while i < components.count {
                // 一对句子
                var coupleSentence: [String] = []
                if i + 1 < components.count {
                    coupleSentence.append(components[i])
                    coupleSentence.append(components[i + 1])
                }
                tmpPoemQuestion.append(coupleSentence)
                i += 2
            }
            // 一首诗
            let tmpPoem = [poemName : tmpPoemQuestion]
            poems.append(tmpPoem)
        }
    }
    
    // 播放回答正确与否的语音反馈
    func playAnswerFeedBack(isCorrect: Bool) {
        var url = URL(string: "")
        if isCorrect {
            url = correctAudioFileURL
        } else {
            url = wrongAudioFileURL
        }
        // 创建音频播放器
        do {
            guard let url = url else { return }
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            // 准备播放音频
            audioPlayer?.prepareToPlay()
            
            // 设置代理
            audioPlayer?.delegate = self
            
            // 播放音频
            audioPlayer?.play()
        } catch {
            self.audioTimer?.invalidate()
            debugPrint("无法创建音频播放器: \(error.localizedDescription)")
        }
    }
    
    // 播放当前诗句语音
    func playPoetSound() {
        audioTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(playPoetSoundAnimation), userInfo: nil, repeats: true)
        // 传文本，请求文本
        if isReachable {
            requestTextAudio(text: currentHalfSentenceIndex == 0 ? self.poemAnswerTextField1.text ?? "" : self.poemAnswerTextField2.text ?? "")
        } else {
            audioTimer?.invalidate()
        }
    }
    
    // 请求具体文本音频
    func requestTextAudio(text: String) {
        let parameters: [String: Any] = [
                "poet_id": poetId,
                "text": text
            ]
        request = AF.request("\(audioDetailURL)/verse", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { [weak self] response in
            guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    do {
                        try data.write(to: self.audioFileURL)
                        debugPrint("音频文件保存成功：\(self.audioFileURL.absoluteString)")
                        // 创建音频播放器并播放
                        self.createAndPlayAudioPlayer()
                    } catch {
                        self.audioTimer?.invalidate()
                        debugPrint("保存音频文件失败：\(error)")
                    }
                case .failure(let error):
                        self.audioTimer?.invalidate()
                    debugPrint("POST 请求失败：\(error)")
                    // 在这里处理失败的情况
                }
            }
    }
    
    // 创建音频播放器并播放
    func createAndPlayAudioPlayer() {
        // 创建音频播放器
        do {
            
            audioPlayer = try AVAudioPlayer(contentsOf: self.audioFileURL)
            
            // 准备播放音频
            audioPlayer?.prepareToPlay()
            
            // 设置代理
            audioPlayer?.delegate = self
            
            // 播放音频
            audioPlayer?.play()
        } catch {
            self.audioTimer?.invalidate()
            debugPrint("无法创建音频播放器: \(error.localizedDescription)")
        }
    }
    
    // 播放完成回调
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioTimer?.invalidate()
        if flag {
            debugPrint("音频播放完成")
        } else {
            debugPrint("音频播放失败")
        }
    }
    
    // 播放诗人语音动画
    @objc func playPoetSoundAnimation() {
        poetSoundAnimationView.play()
    }
    
    // 抽取题目
    func getCurrentQuestion() {
        // 生成一个介于0和poems.count之间的随机整数
        var randomPoemIndex = Int(arc4random_uniform(UInt32(poems.count)))
        let sentenceCount = poems[randomPoemIndex].first?.value.count ?? 0
        let tmp = Int(sentenceCount / 2 - 1)
        let random = Int(arc4random_uniform(UInt32(tmp + 1)))
        var randomSentenceIndex = random * 2
        
        // 连续不重复次数
        var fequencyTime = 5
        
        // 判断 重复
        while existPoemIndex.keys.contains(randomPoemIndex) && ((existPoemIndex[randomPoemIndex]?.contains(randomSentenceIndex)) != nil) && fequencyTime == 0 {
            randomPoemIndex = Int(arc4random_uniform(UInt32(poems.count)))
            let sentenceCount = poems[randomPoemIndex].first?.value.count ?? 0
            let tmp = Int(sentenceCount / 2 - 1)
            let random = Int(arc4random_uniform(UInt32(tmp + 1)))
            randomSentenceIndex = random * 2
            fequencyTime -= 1
        }
        
        // 清空已存在内容
        if fequencyTime == 0 {
            existPoemIndex.removeAll()
        }
        
        // 加入已出现题目库中
        if existPoemIndex[randomPoemIndex] != nil {
            existPoemIndex[randomPoemIndex]?.append(randomSentenceIndex)
        } else {
            existPoemIndex[randomPoemIndex] = [randomSentenceIndex]
        }
        
        // 抽取上下半句
        currentHalfSentenceIndex = Int(arc4random_uniform(UInt32(2)))
        currentPoemIndex = randomPoemIndex
        currentSentenceIndex = randomSentenceIndex
    }
    
    // 根据抽取题目配制UI
    func setQuestionUI() {
        poemAnswerTextField1.placeholder = "请填写答案"
        poemAnswerTextField2.placeholder = "请填写答案"
        poemAnswerTextField1.textColor = .black
        poemAnswerTextField2.textColor = .black
        if currentHalfSentenceIndex == 0 {
            answerSentenceTag1.isHidden = true
            answerSentenceTag2.isHidden = false
            poemAnswerTextField1.isEnabled = false
            poemAnswerTextField2.isEnabled = true
            poemAnswerTextField1.text = poems[currentPoemIndex].first?.value[currentSentenceIndex][currentHalfSentenceIndex] ?? ""
            poemAnswerTextField2.text = ""
        } else {
            answerSentenceTag1.isHidden = false
            answerSentenceTag2.isHidden = true
            poemAnswerTextField1.isEnabled = true
            poemAnswerTextField2.isEnabled = false
            poemAnswerTextField1.text = ""
            poemAnswerTextField2.text = poems[currentPoemIndex].first?.value[currentSentenceIndex][currentHalfSentenceIndex] ?? ""
        }
        // 更新诗名
        poemNameLabel.text = "——《\(String(describing: poems[currentPoemIndex].keys.first ?? ""))》"
    }
    
    // 检验答案是否正确
    func checkAnswer() -> Bool {
        if poemAnswerTextField1.text == poems[currentPoemIndex].first?.value[currentSentenceIndex][0] ?? "" &&
            poemAnswerTextField2.text == poems[currentPoemIndex].first?.value[currentSentenceIndex][1] ?? "" {
            // 重置提示次数
            tipsCount = 0
            return true
        }
        return false
    }
    
    // 打印题目库
    func printQuestionData() {
        for i in poems {
            for (j,k) in i {
                print(j)
                for m in k {
                    print(m)
                }
            }
        }
    }
    
    // 点击提示
    @objc func tipHandle() {
        if currentHalfSentenceIndex == 0 {
            let ansText = poems[currentPoemIndex].first?.value[currentSentenceIndex][1] ?? ""
            poemAnswerTextField2.text = tipsCount == 0 ? String(ansText.prefix(2)) : ansText
            poemAnswerTextField2.textColor = .red
            tipsCount += 1
        } else {
            let ansText = poems[currentPoemIndex].first?.value[currentSentenceIndex][0] ?? ""
            poemAnswerTextField1.text = tipsCount == 0 ? String(ansText.prefix(2)) : ansText
            poemAnswerTextField1.textColor = .red
            tipsCount += 1
        }
    }
    
    // 点击下一题提交答案
    @objc func commitAnswer() {
        audioPlayer?.stop()
        if answerRightCount + 1 == answerNeedRightCount {
            nextQuestionButton.setTitle("提交", for: .normal)
        }
        if checkAnswer() {
            // 轻量级震动
            lightFeedBack()
            
            getCurrentQuestion()
            setQuestionUI()
            playPoetSound()
            if answerRightCount == answerNeedRightCount {
                showFinishView()
                return
            }
            playAnswerFeedBack(isCorrect: true)
            showCheckView(isCorrect: true)
            answerRightCount += 1
        } else {
            // 重量级震动
            weightFeedBack()
            playAnswerFeedBack(isCorrect: false)
            showCheckView(isCorrect: false)
        }
    }
    
    // 展示验证结果的View
    func showCheckView(isCorrect: Bool) {
        currentCheck = isCorrect
        checkLabel.isHidden = false
        maskView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.checkLabel.isHidden = true
            self.maskView.isHidden = true
        }
    }
    
    // 提交结果的View
    func showFinishView() {
        maskView.isHidden = false
        finishView.isHidden = false
    }
    
    // 点击继续挑战按钮
    @objc func continueHandle() {
        maskView.isHidden = true
        finishView.isHidden = true
        //重置
        resetAnswerVC()
        // 难度增加五题
        answerNeedRightCount += 5
        setFinishViewLabel()
    }
    
    // 点击结束挑战按钮
    @objc func exitHandle() {
        maskView.isHidden = false
        finishView.isHidden = false
        dismissCurrentVC()
    }
    
    // 重置
    func resetAnswerVC() {
        tipsCount = 0
        answerRightCount = 0
        nextQuestionButton.setTitle("下一题", for: .normal)
    }
    
    // 隐藏键盘
    @objc func hideKeyboard() {
        // 取消 textField 的第一响应者状态，即隐藏键盘
        poemAnswerTextField1.resignFirstResponder()
        poemAnswerTextField2.resignFirstResponder()
    }
    
    // dimiss当前View
    @objc func dismissCurrentVC() {
        hero.dismissViewController()
        audioPlayer?.stop()
        request?.cancel()
    }
}
