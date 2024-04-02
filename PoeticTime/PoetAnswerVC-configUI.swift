//
//  PoetAnswerVC-configUI.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/3.
//

import UIKit
import SnapKit

extension PoetAnswerVC {
    // 配制回答完成页面的Label样式
    func setFinishViewLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // 调整行间距
        let content = "挑战成功\n本次答对\(answerNeedRightCount)题"
        // 整体样式
        var customAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: "#969696".pt_argbColor ?? .black
            ]
        var attributedString = NSMutableAttributedString(string: content, attributes: customAttributes)
        finishViewLabel.attributedText = attributedString
        let range = NSMakeRange(0, content.count)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        if let range = content.range(of: String("\(answerNeedRightCount)")) {
            let nsRange = NSRange(range, in: content)
            // 部分样式
            let customSubAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: "#FF0000".pt_argbColor ?? .red // 自定义部分颜色
            ]
            attributedString.addAttributes(customSubAttributes, range: nsRange)
        }
        
        if let range = content.range(of: String("挑战成功")) {
            let nsRange = NSRange(range, in: content)
            // 部分样式
            let customSubAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.black
            ]
            attributedString.addAttributes(customSubAttributes, range: nsRange)
        }
        
        finishViewLabel.attributedText = attributedString
    }
    
    // 配制UI
    func setAnswerViewUI() {
        self.view.backgroundColor = .white
        // 添加手势识别器来隐藏键盘
        let hideKeyBoardTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // 将手势识别器添加到视图上
        view.addGestureRecognizer(hideKeyBoardTap)
        view.addSubview(backgroundImageView)
        view.addSubview(backButton)
        view.addSubview(poetLabel)
        view.addSubview(poetImageView)
        view.addSubview(poetSoundAnimationView)
        view.addSubview(answerQuestionContent)
        view.addSubview(maskView)
        view.addSubview(checkLabel)
        view.addSubview(finishView)
        finishView.addSubview(finishImageView)
        finishView.addSubview(finishViewLabel)
        finishView.addSubview(stackButtonView)
        view.addSubview(poemAnswerSoundButton)
        poemAnswerSoundButton.addSubview(poetRecordAnimationView)
        answerQuestionContent.addSubview(answerSentenceTag1)
        answerQuestionContent.addSubview(answerSentenceLine1)
        answerQuestionContent.addSubview(answerSentenceTag2)
        answerQuestionContent.addSubview(answerSentenceLine2)
        answerQuestionContent.addSubview(poemNameLabel)
        answerQuestionContent.addSubview(nextQuestionButton)
        answerQuestionContent.addSubview(tipsImageButton)
        answerQuestionContent.addSubview(tipsButton)
        answerQuestionContent.addSubview(poemAnswerTextField1)
        answerQuestionContent.addSubview(poemAnswerTextField2)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(44)
            make.width.height.equalTo(32)
        }
        
        poetLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarHeight)
        }
        
        poetImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(poetLabel.snp.bottom).offset(8)
            make.height.width.equalTo(78)
        }
        
        poetSoundAnimationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(poetImageView.snp.bottom).offset(2)
            make.height.equalTo(33)
            make.width.equalTo(66)
        }
        
        answerQuestionContent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(poetSoundAnimationView.snp.bottom).offset(8)
            make.width.equalTo(334)
            make.height.equalTo(432)
        }
        
        poemAnswerSoundButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-66)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(90)
        }
        
        maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        checkLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(240)
            make.height.equalTo(60)
        }
        
        finishView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(240)
            make.height.equalTo(340)
        }
        
        finishImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(72)
            make.width.height.equalTo(95)
        }
        
        finishViewLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(finishImageView.snp.bottom).offset(8)
            make.width.height.equalTo(95)
        }
        
        continueButton.snp.makeConstraints { make in
            make.width.equalTo(exitButton)
        }
        
        stackButtonView.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(36)
        }
        
        poetRecordAnimationView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(44)
        }
        
        answerSentenceTag1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(129)
            make.left.equalToSuperview().offset(22)
            make.width.equalTo(6)
            make.height.equalTo(33)
        }
        
        answerSentenceLine1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(160)
            make.left.equalToSuperview().offset(64)
            make.width.equalTo(230)
            make.height.equalTo(2)
        }
        
        answerSentenceTag2.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(189)
            make.left.equalToSuperview().offset(22)
            make.width.equalTo(6)
            make.height.equalTo(33)
        }
        
        answerSentenceLine2.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(220)
            make.left.equalToSuperview().offset(64)
            make.width.equalTo(230)
            make.height.equalTo(2)
        }
        
        poemNameLabel.snp.makeConstraints { make in
            make.top.equalTo(answerSentenceLine2.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
        }
        
        nextQuestionButton.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview().offset(-8)
            make.width.equalTo(136)
            make.height.equalTo(31)
        }
        
        tipsImageButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
        tipsButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(82)
            make.height.equalTo(20)
        }
        
        poemAnswerTextField1.snp.makeConstraints { make in
            make.left.equalTo(answerSentenceLine1.snp.left)
            make.top.equalTo(answerSentenceTag1.snp.top).offset(-2)
        }

        poemAnswerTextField2.snp.makeConstraints { make in
            make.left.equalTo(answerSentenceLine2.snp.left)
            make.top.equalTo(answerSentenceTag2.snp.top).offset(-2)
        }
    }
}

extension PoetAnswerVC: UITextFieldDelegate {
    // 编辑时保持字体黑色
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.textColor = .black
    }
    
    // 当用户按下 Return 键时调用
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 取消 textField 的第一响应者状态，即结束编辑
        textField.resignFirstResponder()
        return true
    }
}
