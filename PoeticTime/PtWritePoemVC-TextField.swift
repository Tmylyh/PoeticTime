//
//  PtWritePoemVC-TextField.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/5.
//

import UIKit

extension PtWritePoemVC: UITextFieldDelegate, UITextViewDelegate {
    // 当用户按下 Return 键时调用
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 取消 textField 的第一响应者状态，即结束编辑
        if textField.text == "" {
            textField.text = textField.placeholder
        }
        textField.resignFirstResponder()
        updatePoemName()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 内容有变更
        isChanged = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        isChanged = true
        return true
    }
}
