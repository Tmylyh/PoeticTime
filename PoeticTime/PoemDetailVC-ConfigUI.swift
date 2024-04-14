//
//  PoemDetailVC-ConfigUI.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/7.
//

import UIKit
import SnapKit
import AVFoundation

extension PoemDetailVC {
    // 配制诗词详情页UI
    func setPoemDetailUI() {
        let star = isStar ? "is" : "no"
        starButton.setImage(UIImage(named: "poetic_time_poem_card_\(star)_star_image"), for: .normal)
        view.addSubview(backGroundImageView)
        view.addSubview(backButton)
        view.addSubview(starButton)
        view.addSubview(chatQuestionButton)
        view.addSubview(vrButton)
        view.addSubview(poemNameLabel)
        view.addSubview(poetNameAndDynastyLabel)
        view.addSubview(poemBodyTextView)
        view.addSubview(playPauseButton)
        view.addSubview(progressSlider)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationLabel)
        
        backGroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(44)
            make.height.width.equalTo(32)
        }
        
        starButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(32)
        }
        
        chatQuestionButton.snp.makeConstraints { make in
            make.top.equalTo(starButton.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(32)
        }
        
        vrButton.snp.makeConstraints { make in
            make.top.equalTo(chatQuestionButton.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(32)
        }
        
        poemNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(90)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        poetNameAndDynastyLabel.snp.makeConstraints { make in
            make.top.equalTo(poemNameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        poemBodyTextView.snp.makeConstraints { make in
            make.top.equalTo(poetNameAndDynastyLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-132)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        progressSlider.snp.makeConstraints { make in
            make.top.equalTo(playPauseButton.snp.top).offset(-32)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(progressSlider.snp.bottom)
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(60)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(progressSlider.snp.bottom)
            make.right.equalToSuperview().offset(-5)
            make.width.equalTo(60)
        }
    }

    // 配制播放器
    func setupAudioPlayer() {
        guard let audioURL = fileURL else {
            debugPrint("Audio file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()

            if let duration = audioPlayer?.duration {
                progressSlider.maximumValue = Float(duration)
                updateDurationLabel(duration: duration)
            }
            // 计时更新进度条
            timer = CADisplayLink(target: self, selector: #selector(updateProgress))
            timer?.add(to: .main, forMode: RunLoop.Mode.common)
        } catch {
            debugPrint("Error initializing AVAudioPlayer: \(error.localizedDescription)")
        }
    }

    // 更新时长标签
    func updateDurationLabel(duration: TimeInterval) {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    // 播放按钮
    @objc func playPauseButtonTapped(_ sender: UIButton) {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
            // 获取系统提供的图标
            let image = UIImage(systemName: "play.circle", withConfiguration: imageConfiguration)
            playPauseButton.setImage(image, for: .normal)
        } else {
            audioPlayer?.play()
            let image = UIImage(systemName: "pause.circle", withConfiguration: imageConfiguration)
            playPauseButton.setImage(image, for: .normal)
        }
    }

    // 拉动进度条
    @objc func progressSliderValueChanged(_ sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(progressSlider.value)
    }

    // 更新进度
    @objc func updateProgress() {
        let currentTime = audioPlayer?.currentTime ?? 0
        progressSlider.value = Float(currentTime)
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        currentTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        if durationLabel.text == currentTimeLabel.text {
            // 获取系统提供的图标
            let image = UIImage(systemName: "play.circle", withConfiguration: imageConfiguration)
            playPauseButton.setImage(image, for: .normal)
        }
    }

    // 处理字符串,第偶数个符号后面加换行符
    func addNewlineAfterEvenPunctuation(input: String) -> String {
        // 定义要加换行符的标点符号
        let punctuationCharacters: Set<Character> = ["。", "！", "？", "，"]
        var output = ""
        var punctuationCount = 0

        // 遍历字符串
        for char in input {
            output.append(char)

            if punctuationCharacters.contains(char) {
                // 如果是标点符号
                punctuationCount += 1
                // 如果是第偶数个标点符号，则在后面加一个换行符
                if punctuationCount % 2 == 0 {
                    output.append("\n")
                }
            }
        }
        return output
    }
}
