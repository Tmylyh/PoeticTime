//
//  Constant.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/30.
//

import UIKit

// 朝代
struct Dynasty {
    let dynastyId: String
    let dynastyName: String
    let dynastyInfo: String
}

// 诗词
struct Poem {
    let poemId: String
    let poemName: String
    let poetId: String
    let dynastyId: String
    let poemBody: String
}

// 诗人
struct Poet {
    let poetId: String
    let poetName: String
    let dynastyId: String
    let poetInfo: String
}

// 总数据
var dynastyData: [Dynasty] = []
var poemData: [Poem] = []
var poetData: [Poet] = []

// 跳转动画文本
let animationText: [String] = ["贞观之治四海宁             文化初兴气象新", "开元盛世歌繁华             万国衣冠拜冕旒", "安史之乱山河破             风雨飘摇度时艰", "末世衰微叹奈何             夕阳无限映江波", "庆历新政启新篇             文化昌盛耀九天", "偏安一隅保家国             临安城下思故国", "蒙古雄风扫欧亚             文化交融显华章", "永乐大典耀古今             海上丝绸扬国威", "康乾盛世百业兴             闭关锁国渐沉沦"]

/// 初始化imageView的Rect
let viewInitRect = CGRect(x: 0, y: 0, width: 100, height: 100)

/// tabBar高度
let ptTabBarHeight: CGFloat = 120

/// cellID
let kPtCardCollectionViewCell = "PtCardCollectionViewCell"
let kPtDynastyCollectionViewCell = "PtDynastyCollectionViewCell"
let kPtPoemCell = "PtPoemCell"

/// UIBounds
let Bounds = UIScreen.main.bounds

/// chatVC的请求URL
let chatURL = "http://4ed115f.r12.cpolar.top"

/// 替换符
/// 自定义替换换行符的序列，防止换行符导致json解析不出来
let kReturnKey = "abcdefg"
let kBackKey = "abcdeff"

/// 朗读整首诗的请求URL
let audioURL = "http://3c06e3d3.r5.cpolar.top"

/// 请求的是整首诗还是一句
enum AudioType: String {
    case text = "text"
    case verse = "verse"
}

/// 系统状态栏高度
var statusBarHeight: Int {
    get {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let statusBarManager = windowScene.statusBarManager {
                let statusBarFrame = statusBarManager.statusBarFrame
                let statusBarHeight = statusBarFrame.height
                return Int(statusBarHeight)
            }
        }
        return 44
    }
}
