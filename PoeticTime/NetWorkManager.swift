//
//  NetWorkManager.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/1.
//

import Foundation
import Network

// 使用方式
// 设置网络状态改变的处理闭包
// NetworkManager.shared.networkStatusChangeHandler = { isReachable in
//     if !isReachable {
//         // 回主线程操作
//         OperationQueue.main.addOperation {
//             self.poemAnswerSoundButton.setTitle("连网识别", for: .normal)
//         }
//     }
// }

class NetworkManager {
    static let shared = NetworkManager() // 单例
    
    private let monitor = NWPathMonitor()
    private var isMonitoring = false

    // 定义一个闭包类型，用于在网络状态改变时通知调用者
    typealias NetworkStatusChangeHandler = (Bool) -> Void
    var networkStatusChangeHandler: NetworkStatusChangeHandler?

    private init() {
        // 开始监听网络状态
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        guard !isMonitoring else { return }
        
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                // 有网络连接
                self?.networkStatusChangeHandler?(true)
            } else {
                // 无网络连接
                self?.networkStatusChangeHandler?(false)
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        isMonitoring = true
    }
    
    private func stopMonitoring() {
        guard isMonitoring else { return }
        
        monitor.cancel()
        isMonitoring = false
    }
}
