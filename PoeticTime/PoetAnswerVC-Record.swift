//
//  PoetAnswerVC-Record.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/1.
//

import UIKit
import Speech

extension PoetAnswerVC: SFSpeechRecognizerDelegate {
    
    // 按下识别按钮
    @objc func touchDownHandle() {
        do {
            try startRecording()
            poemAnswerSoundButton.setTitle("正在收听", for: [])
        } catch {
            poemAnswerSoundButton.setTitle("不可用", for: [])
        }
    }
    
    // 范围内抬起
    @objc func touchUpInsideHandle() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        poemAnswerSoundButton.isEnabled = false
        poemAnswerSoundButton.setTitle("正在识别", for: .disabled)
    }
    
    // 范围外抬起
    @objc func touchUpOutsideHandle() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        poemAnswerSoundButton.isEnabled = false
        poemAnswerSoundButton.setTitle("取消中", for: .disabled)
    }
    
    // 开始语音识别
    func startRecording() throws {
        
        // 取消之前正在运行的语音识别任务（如果有）
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // 配置应用程序的音频会话
        let audioSession = AVAudioSession.sharedInstance()
        
        // 设置了音频会话的类别为 .record，意味着这是一个用于录音的音频会话。mode 设置为 .measurement 表示此会话是用于测量的。options 中的 .duckOthers 表示当此音频会话激活时，其他音频会话会降低音量。
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        
        // 激活了音频会话，使其生效，并且选项 .notifyOthersOnDeactivation 表示在该音频会话被停用时，通知其他音频会话。
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // 这里获取了音频引擎的输入节点，可以用来接收录音设备的音频输入。这是语音识别过程中接收录音数据的地方。
        let inputNode = audioEngine.inputNode

        // 创建并配置语音识别请求
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("语音识别请求创建失败") }
        
        // 若为true，在识别过程中会返回部分结果。这样做可以让用户及时看到识别的中间结果，而不是等待整个语音输入结束后才显示结果。
        recognitionRequest.shouldReportPartialResults = false
        
        // 不要求在设备上进行语音识别，允许将语音数据传输到远程服务器进行识别
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // 创建语音识别任务，分配给 recognitionTask
        guard let speechRecognizer = speechRecognizer else { return }
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            // 标记识别结果是否为最终结果(用来处理流式输出的case）
            var isFinal = false
            
            if let result = result {
                // 检查识别结果是否存在。如果存在，就更新文本视图 textView，显示最佳识别结果的格式化字符串，并将 isFinal 标记为 result.isFinal，表示是否为最终结果。
                self.soundText = result.bestTranscription.formattedString
                isFinal = result.isFinal
                // 打印识别结果
                // debugPrint("Text \(result.bestTranscription.formattedString)")
            }
            
            if error != nil || isFinal {
                // 停止音频引擎，移除音频输入节点的监听，并重置语音识别请求和任务对象。然后重新启用录音按钮
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.poemAnswerSoundButton.isEnabled = true
                self.poemAnswerSoundButton.setTitle("长按识别", for: [])
            }
        }

        // 配置音频输入，即麦克风输入节点。
        // 获取了麦克风输入节点的音频输出格式，以便配置音频输入。
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        // 安装了一个监听器（Tap）到音频输入节点上，监听器会在音频输入节点收到新的音频数据时被触发。
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        // 设备准备、启动
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // 用于在语音识别器的可用性发生变化时进行响应
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            poemAnswerSoundButton.isEnabled = true
            poemAnswerSoundButton.setTitle("长按识别", for: [])
        } else {
            poemAnswerSoundButton.isEnabled = false
            poemAnswerSoundButton.setTitle("不可用", for: .disabled)
        }
    }
}
