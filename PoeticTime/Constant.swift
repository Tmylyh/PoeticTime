//
//  Constant.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/30.
//

import Foundation

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
}

var dynastyData: [Dynasty] = []
var poemData: [Poem] = []
var poetData: [Poet] = []
