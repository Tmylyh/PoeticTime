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
    let poemStar: Bool
}

// 诗人
struct Poet {
    let poetId: String
    let poetName: String
    let dynastyId: String
    let poetInfo: String
}

// 用户诗词
struct UserPoem {
    let userPoemId: String
    let userPoemName: String
    let userPoemDate: Double
    let userPoemDynasty: String
    let userPoemBody: String
    let userPoemImageData: Data
}

// 用户信息
struct UserInfo: Codable {
    let userName: String
    let userIntro: String
    let userImageData: Data
}

/// 总数据
var dynastyData: [Dynasty] = []
var poemData: [Poem] = []
var poetData: [Poet] = []
var userPoemData: [UserPoem] = []
var userInfo: UserInfo = UserInfo(userName: "", userIntro: "", userImageData: Data())

/// 是否是第一次打开App
var isFirstLaunch = true

/// 用户数据key
let kUserInfoKey = "PoeticTimeUserInfoKey"

/// 默认用户名
let initUserName = "诗小韵"

/// 默认用户座右铭
let initUserIntro = "点击这里，创建专属诗句座右铭"

/// 默认用户头像
let initUserImageName = "poetic_time_write_poem_image"

/// 跳转动画文本
let animationText: [String] = ["贞观之治四海宁             文化初兴气象新", "开元盛世歌繁华             万国衣冠拜冕旒", "安史之乱山河破             风雨飘摇度时艰", "末世衰微叹奈何             夕阳无限映江波", "庆历新政启新篇             文化昌盛耀九天", "偏安一隅保家国             临安城下思故国", "蒙古雄风扫欧亚             文化交融显华章", "永乐大典耀古今             海上丝绸扬国威", "康乾盛世百业兴             闭关锁国渐沉沦"]

/// 初始化imageView的Rect
let viewInitRect = CGRect(x: 0, y: 0, width: 100, height: 100)

/// tabBar高度
let ptTabBarHeight: CGFloat = 120

/// cellID
let kPtCardCollectionViewCell = "PtCardCollectionViewCell"
let kPtDynastyCollectionViewCell = "PtDynastyCollectionViewCell"
let kPtPoemCell = "PtPoemCell"
let kDynastyUserPoemCell = "DynastyUserPoemCell"
let kPtSettingCellID = "PtSettingCellID"

/// UIBounds
let Bounds = UIScreen.main.bounds

/// chatVC的请求URL
let chatURL = "http://3e707a7a.r16.cpolar.top"

/// 替换符
/// 自定义替换换行符的序列，防止换行符导致json解析不出来
let kReturnKey = "abcdefg"
let kBackKey = "abcdeff"

/// 朗读整首诗的请求URL
let audioURL = "http://3c06e3d3.r5.cpolar.top"

/// 朗读指定文本的请求URL
let audioDetailURL = "http://b180903.r22.cpolar.top"

/// 回答正确文本集
let answerCorrectFeedBackText = "吾诗遇知音，甚妙。"

/// 回答错误文本集
let answerWrongFeedBackText = "诗中深意，汝尚未解。"
/// 对应URL
var correctAudioFileURL = URL(string: "")
var wrongAudioFileURL = URL(string: "")

/// 初始化用户诗词数据
let initUserPoemName = "故人西辞黄鹤楼"
let initUserPoemBody = "写点什么留在这里"
let initUserPoemImageName = "poetic_time_write_poem_image"

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
