//
//  Dao.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/29.
//

import Foundation
import SQLite

// 表类型
enum TableType: String, CaseIterable {
    case dynasty = "dynasty"
    case poem = "poem"
    case poet = "poet"
    case userPoem = "userPoem"
}

// 数据库参数
public class DBInfo {
    var poetId = ""
    var poetName = ""
    var poetInfo = ""
    var poemId = ""
    var poemName = ""
    var poemBody = ""
    var dynastyId = ""
    var dynastyName = ""
    var dynastyInfo = ""
    // TODO: -@lyh 存沙盒
//    var userName = ""
//    var userInfo = ""
    var userPoemId = ""
    var userPoemName = ""
    var userPoemDate: Double = 0
    var userPoemDynasty = ""
    var userPoemBody = ""
    var userPoemImageData: Data = Data()
    var tableType: TableType = .dynasty
    
    /// 朝代数据的初始化方法
    init(dynastyId: String, dynastyName: String, dynastyInfo: String) {
        self.dynastyId = dynastyId
        self.dynastyName = dynastyName
        self.dynastyInfo = dynastyInfo
        self.tableType = .dynasty
    }
    
    /// 诗词数据的初始化方法
    init(poemId: String, poemName: String, poetId: String, dynastyId: String, poemBody: String) {
        self.poemId = poemId
        self.poemName = poemName
        self.poetId = poetId
        self.dynastyId = dynastyId
        self.poemBody = poemBody
        self.tableType = .poem
    }
    
    /// 诗人数据的初始化方法
    init(poetId: String, poetName: String, dynastyId: String, poetInfo: String) {
        self.poetId = poetId
        self.poetName = poetName
        self.dynastyId = dynastyId
        self.poetInfo = poetInfo
        self.tableType = .poet
    }
    
    /// 用户诗数据的初始化方法
    init(userPoemId: String, userPoemName: String, userPoemDate: Double, userPoemDynasty: String, userPoemBody: String, userPoemImageData: Data) {
        self.userPoemId = userPoemId
        self.userPoemName = userPoemName
        self.userPoemDate = userPoemDate
        self.userPoemDynasty = userPoemDynasty
        self.userPoemBody = userPoemBody
        self.userPoemImageData = userPoemImageData
        self.tableType = .userPoem
    }
    
    init() {}
}

/// 数据库管理
public class PoeticTimeDao: NSObject {
    
    // 数据库
    static var database: Connection!
    
    // 诗人表
    static let poetTable = Table("poetTable")
    static let poetId = Expression<String>("poetId")
    static let poetName = Expression<String>("poetName")
    static let poetInfo = Expression<String>("poetInfo")
    
    // 诗词表
    static let poemTable = Table("poemTable")
    static let poemId = Expression<String>("poemId")
    static let poemName = Expression<String>("poemName")
    static let poemBody = Expression<String>("poemBody")
    
    // 朝代表
    static let dynastyTable = Table("dynastyTable")
    static let dynastyId = Expression<String>("dynastyId")
    static let dynastyName = Expression<String>("dynastyName")
    static let dynastyInfo = Expression<String>("dynastyInfo")
    
    // 用户诗词表
    static let userPoemTable = Table("userPoemTable")
    static let userPoemId = Expression<String>("userPoemId")
    static let userPoemName = Expression<String>("userPoemName")
    static let userPoemDate = Expression<Double>("userPoemDate")
    static let userPoemDynasty = Expression<String>("userPoemDynasty")
    static let userPoemBody = Expression<String>("userPoemBody")
    static let userPoemImageData = Expression<Data>("userPoemImageData")
    
    /// 连接数据库
    class public func connectDB() {
        do {
            // 用户文件夹
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("PoeticTimeUsers").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            debugPrint(error)
        }
    }
    
    /// 建表
    class public func createTableIfNotExist() {
        debugPrint("——————CREATE START——————")
        createDynastyTable()
        createPoetTable()
        createPoemTable()
        createUserPoemTable()
    }
    
    // 建诗词表
    class private func createPoemTable() {
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='poemTable'"
        do {
            // 执行查询
            if try self.database.scalar(query) == nil {
                let createTable = poemTable.create { (poemTable) in
                    poemTable.column(poemId, primaryKey: true)
                    poemTable.column(poemName)
                    poemTable.column(poetId)
                    poemTable.column(dynastyId)
                    poemTable.column(poemBody)
                    poemTable.foreignKey(dynastyId, references: dynastyTable, dynastyId)
                    poemTable.foreignKey(poetId, references: poetTable, poetId)
                }
                try self.database.run(createTable)
                debugPrint("Created poemTable")
            } else {
                debugPrint("Table 'poemTable' exists.")
            }
        } catch {
            debugPrint(error)
        }
    }
    
    
    // 建诗人表
    class private func createPoetTable() {
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='poetTable'"
        do {
            // 执行查询
            if try self.database.scalar(query) == nil {
                let createTable = poetTable.create { (poetTable) in
                    poetTable.column(poetId, primaryKey: true)
                    poetTable.column(poetName)
                    poetTable.column(dynastyId)
                    poetTable.column(poetInfo)
                    poetTable.foreignKey(dynastyId, references: dynastyTable, dynastyId)
                }
                try self.database.run(createTable)
                debugPrint("Created poetTable")
            } else {
                debugPrint("Table 'poetTable' exists.")
            }
        } catch {
            debugPrint(error)
        }
    }
    
    // 建朝代表
    class private func createDynastyTable() {
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='dynastyTable'"
        do {
            // 执行查询
            if try self.database.scalar(query) == nil {
                let createTable = dynastyTable.create { (dynastyTable) in
                    dynastyTable.column(dynastyId, primaryKey: true)
                    dynastyTable.column(dynastyName)
                    dynastyTable.column(dynastyInfo)
                }
                try self.database.run(createTable)
                debugPrint("Created dynastyTable")
            } else {
                debugPrint("Table 'dynastyTable' exists.")
            }
        } catch {
            debugPrint(error)
        }
    }
    
    
    // 建用户诗词表
    class private func createUserPoemTable() {
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='userPoemTable'"
        do {
            // 执行查询
            if try self.database.scalar(query) == nil {
                let createTable = userPoemTable.create { (userPoemTable) in
                    userPoemTable.column(userPoemId, primaryKey: true)
                    userPoemTable.column(userPoemName)
                    userPoemTable.column(userPoemDate)
                    userPoemTable.column(userPoemDynasty)
                    userPoemTable.column(userPoemBody)
                    userPoemTable.column(userPoemImageData)
                }
                try self.database.run(createTable)
                debugPrint("Created userPoemTable")
            } else {
                debugPrint("Table 'userPoemTable' exists.")
            }
        } catch {
            debugPrint(error)
        }
    }
    
    // 初始化朝代数据
    class private func initDynastyDB() {
        // 读取RTF文件并解析数据
        guard let rtfURL = Bundle.main.url(forResource: "dynasty", withExtension: "rtf") else {
            debugPrint("dynasty.rtf file not found")
            return
        }
        do {
            let data = try Data(contentsOf: rtfURL)
            let attributedString = try! NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            let plainText = attributedString.string
            // 拿到处理后的数据
            let rows = plainText.components(separatedBy: "\n")
            if let db = PoeticTimeDao.database {
                // 插入数据
                let dynastyTable = PoeticTimeDao.dynastyTable
                let dynastyId = PoeticTimeDao.dynastyId
                let dynastyName = PoeticTimeDao.dynastyName
                let dynastyInfo = PoeticTimeDao.dynastyInfo
                try db.transaction {
                    for row in rows {
                        let components = row.components(separatedBy: ",,")
                        if components.count == 3 {
                            let string1 = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string2 = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string3 = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
                            try db.run(dynastyTable.insert(dynastyId <- string1, dynastyName <- string2, dynastyInfo <- string3))
                        } else {
                            print("Invalid format for row: \(row)")
                        }
                    }
                }
            }
        } catch {
            print("Error reading or inserting RTF data: \(error)")
        }
    }
    
    // 初始化诗人数据
    class private func initPoetDB() {
        // 读取RTF文件并解析数据
        guard let rtfURL = Bundle.main.url(forResource: "poet", withExtension: "rtf") else {
            debugPrint("poet.rtf file not found")
            return
        }
        do {
            let data = try Data(contentsOf: rtfURL)
            let attributedString = try! NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            let plainText = attributedString.string
            // 拿到处理后的数据
            let rows = plainText.components(separatedBy: "\n")
            if let db = PoeticTimeDao.database {
                // 插入数据
                let poetTable = PoeticTimeDao.poetTable
                let poetId = PoeticTimeDao.poetId
                let poetName = PoeticTimeDao.poetName
                let dynastyId = PoeticTimeDao.dynastyId
                let poetInfo = PoeticTimeDao.poetInfo
                try db.transaction {
                    for row in rows {
                        let components = row.components(separatedBy: ",,")
                        if components.count == 4 {
                            let string1 = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string2 = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string3 = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string4 = components[3].trimmingCharacters(in: .whitespacesAndNewlines)
                            try db.run(poetTable.insert(poetId <- string1, poetName <- string2, dynastyId <- string3, poetInfo <- string4))
                        } else {
                            print("Invalid format for row: \(row)")
                        }
                    }
                }
            }
        } catch {
            print("Error reading or inserting RTF data: \(error)")
        }
    }
    
    // 初始化诗的数据
    class private func initPoemDB() {
        // 读取RTF文件并解析数据
        guard let rtfURL = Bundle.main.url(forResource: "poem", withExtension: "rtf") else {
            debugPrint("poem.rtf file not found")
            return
        }
        do {
            let data = try Data(contentsOf: rtfURL)
            let attributedString = try! NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            let plainText = attributedString.string
            // 拿到处理后的数据
            let rows = plainText.components(separatedBy: "\n")
            if let db = PoeticTimeDao.database {
                // 插入数据
                let poemTable = PoeticTimeDao.poemTable
                let poemId = PoeticTimeDao.poemId
                let poemName = PoeticTimeDao.poemName
                let poetId = PoeticTimeDao.poetId
                let dynastyId = PoeticTimeDao.dynastyId
                let poemBody = PoeticTimeDao.poemBody
                try db.transaction {
                    for row in rows {
                        let components = row.components(separatedBy: ",,")
                        if components.count == 5 {
                            let string1 = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string2 = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string3 = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string4 = components[3].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string5 = components[4].trimmingCharacters(in: .whitespacesAndNewlines)
                            try db.run(poemTable.insert(poemId <- string1, poemName <- string2, poetId <- string3, dynastyId <- string4, poemBody <- string5))
                        } else {
                            print("Invalid format for row: \(row)")
                        }
                    }
                }
            }
        } catch {
            print("Error reading or inserting RTF data: \(error)")
        }
    }
    
    /// 初始化数据
    class public func initDB(completion: (() -> Void)? = nil) {
        // 建立连接
        PoeticTimeDao.connectDB()
        // 建表
        PoeticTimeDao.createTableIfNotExist()
        initDynastyDB()
        initPoetDB()
        initPoemDB()
    }
    
    /// 打印表数据
    class public func printTable(info: DBInfo, completion: (() -> Void)? = nil) {
        do {
            if let db = PoeticTimeDao.database {
                switch info.tableType {
                case .dynasty:
                    for dynasty in try db.prepare(dynastyTable) {
                        debugPrint("dynastyId: \(dynasty[dynastyId]), dynastyName: \(dynasty[dynastyName]), dynastyInfo: \(dynasty[dynastyInfo])")
                    }
                case .poem:
                    for poem in try db.prepare(poemTable) {
                        debugPrint("poemId: \(poem[poemId]), poemName: \(poem[poemName]), poetId: \(poem[poetId]), dynastyId: \(poem[dynastyId]), poemBody: \(poem[poemBody])")
                    }
                case .poet:
                    for poet in try db.prepare(poetTable) {
                        debugPrint("poetId: \(poet[poetId]), poetName: \(poet[poetName]), dynastyId: \(poet[dynastyId]), poetInfo: \(poet[poetInfo])")
                    }
                case .userPoem:
                    for userPoem in try db.prepare(userPoemTable) {
                        debugPrint("userPoemId: \(userPoem[userPoemId]), userPoemName: \(userPoem[userPoemName]), userPoemDate: \(userPoem[userPoemDate]), userPoemDynasty: \(userPoem[userPoemDynasty]), userPoemBody: \(userPoem[userPoemBody]), userPoemImageData: \(userPoem[userPoemImageData])")
                    }
                }
            }
            completion?()
        } catch {
            debugPrint(error)
        }
    }
    
    /// 读取数据到内存
    // TODO: -@lyh 暂时保留旧版的读方法，待删除
//    class public func readDataOld(completion: (() -> Void)? = nil) {
//        do {
//            if let db = PoeticTimeDao.database {
//                for dynasty in try db.prepare(dynastyTable) {
//                    let dynastyElement = Dynasty(dynastyId: dynasty[dynastyId], dynastyName: dynasty[dynastyName], dynastyInfo: dynasty[dynastyInfo])
//                    if !dynastyData.contains(where: { dynasty in
//                        return dynasty.dynastyId == dynastyElement.dynastyId
//                    }) {
//                        dynastyData.append(dynastyElement)
//                    } else {
//                        // 查找数组中特定唯一值的结构体的索引
//                        if let index = dynastyData.firstIndex(where: { $0.dynastyId == dynasty[dynastyId] }) {
//                            // 更新索引处的元素为新值
//                            dynastyData[index] = Dynasty(dynastyId: dynasty[dynastyId], dynastyName: dynasty[dynastyName], dynastyInfo: dynasty[dynastyInfo])
//                        }
//                    }
//                }
//                for poem in try db.prepare(poemTable) {
//                    let poemElement = Poem(poemId: poem[poemId], poemName: poem[poemName], poetId: poem[poetId], dynastyId: poem[dynastyId], poemBody: poem[poemBody])
//                    if !poemData.contains(where: { poem in
//                        return poem.poemId == poemElement.poemId
//                    }) {
//                        poemData.append(poemElement)
//                    } else {
//                        // 查找数组中特定唯一值的结构体的索引
//                        if let index = poemData.firstIndex(where: { $0.poemId == poem[poemId] }) {
//                            // 更新索引处的元素为新值
//                            poemData[index] = Poem(poemId: poem[poemId], poemName: poem[poemName], poetId: poem[poetId], dynastyId: poem[dynastyId], poemBody: poem[poemBody])
//                        }
//                    }
//                }
//                for poet in try db.prepare(poetTable) {
//                    let poetElement = Poet(poetId: poet[poetId], poetName: poet[poetName], dynastyId: poet[dynastyId], poetInfo: poet[poetInfo])
//                    if !poetData.contains(where: { poet in
//                        return poet.poetId == poetElement.poetId
//                    }) {
//                        poetData.append(poetElement)
//                    } else {
//                        // 查找数组中特定唯一值的结构体的索引
//                        if let index = poetData.firstIndex(where: { $0.poetId == poet[poetId] }) {
//                            // 更新索引处的元素为新值
//                            poetData[index] = Poet(poetId: poet[poetId], poetName: poet[poetName], dynastyId: poet[dynastyId], poetInfo: poet[poetInfo])
//                        }
//                    }
//                }
//                for userPoem in try db.prepare(userPoemTable) {
//                    let userPoemElement = UserPoem(userPoemId: userPoem[userPoemId], userPoemName: userPoem[userPoemName], userPoemDate: userPoem[userPoemDate], userPoemDynasty: userPoem[userPoemDynasty], userPoemBody: userPoem[userPoemBody], userPoemImageData: userPoem[userPoemImageData])
//                    if !userPoemData.contains(where: { userPoem in
//                        return userPoem.userPoemId == userPoemElement.userPoemId
//                    }) {
//                        userPoemData.append(userPoemElement)
//                    } else {
//                        // 查找数组中特定唯一值的结构体的索引
//                        if let index = userPoemData.firstIndex(where: { $0.userPoemId == userPoem[userPoemId] }) {
//                            // 更新索引处的元素为新值
//                            userPoemData[index] = UserPoem(userPoemId: userPoem[userPoemId], userPoemName: userPoem[userPoemName], userPoemDate: userPoem[userPoemDate], userPoemDynasty: userPoem[userPoemDynasty], userPoemBody: userPoem[userPoemBody], userPoemImageData: userPoem[userPoemImageData])
//                        }
//                    }
//                }
//            }
//            completion?()
//        } catch {
//            debugPrint(error)
//        }
//    }
    
    /// 读取数据到内存
    class public func readData(completion: (() -> Void)? = nil) {
        do {
            if let db = PoeticTimeDao.database {
                dynastyData.removeAll()
                for dynasty in try db.prepare(dynastyTable) {
                    let dynastyElement = Dynasty(dynastyId: dynasty[dynastyId], dynastyName: dynasty[dynastyName], dynastyInfo: dynasty[dynastyInfo])
                    dynastyData.append(dynastyElement)
                }
                
                poemData.removeAll()
                for poem in try db.prepare(poemTable) {
                    let poemElement = Poem(poemId: poem[poemId], poemName: poem[poemName], poetId: poem[poetId], dynastyId: poem[dynastyId], poemBody: poem[poemBody])
                    poemData.append(poemElement)
                }
                poetData.removeAll()
                for poet in try db.prepare(poetTable) {
                    let poetElement = Poet(poetId: poet[poetId], poetName: poet[poetName], dynastyId: poet[dynastyId], poetInfo: poet[poetInfo])
                    poetData.append(poetElement)
                }
                userPoemData.removeAll()
                for userPoem in try db.prepare(userPoemTable) {
                    let userPoemElement = UserPoem(userPoemId: userPoem[userPoemId], userPoemName: userPoem[userPoemName], userPoemDate: userPoem[userPoemDate], userPoemDynasty: userPoem[userPoemDynasty], userPoemBody: userPoem[userPoemBody], userPoemImageData: userPoem[userPoemImageData])
                    userPoemData.append(userPoemElement)
                }
            }
            completion?()
        } catch {
            debugPrint(error)
        }
    }
    
    /// 插入元素
    class public func insertElement(info: DBInfo, completion: (() -> Void)? = nil) {
        if let db = PoeticTimeDao.database {
            do {
                switch info.tableType {
                case .dynasty:
                    try db.run(dynastyTable.insert(dynastyId <- info.dynastyId, dynastyName <- info.dynastyName, dynastyInfo <- info.dynastyInfo))
                case .poet:
                    try db.run(poetTable.insert(poetId <- info.poetId, poetName <- info.poetName, dynastyId <- info.dynastyId, poetInfo <- info.poetInfo))
                case .poem:
                    try db.run(poemTable.insert(poemId <- info.poemId, poemName <- info.poemName, poetId <- info.poetId, dynastyId <- info.dynastyId, poemBody <- info.poemBody))
                case .userPoem:
                    try db.run(userPoemTable.insert(userPoemId <- info.userPoemId, userPoemName <- info.userPoemName, userPoemDate <- info.userPoemDate, userPoemDynasty <- info.userPoemDynasty, userPoemBody <- info.userPoemBody, userPoemImageData <- info.userPoemImageData))
                }
                // 读取数据
                readData()
                completion?()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    /// 更新元素(必须全部字段传入）
    class public func updateElement(info: DBInfo, completion: (() -> Void)? = nil) {
        do {
            var updateId: String = ""
            switch info.tableType {
            case .dynasty:
                updateId = info.dynastyId
                let updateElement = dynastyTable.filter(dynastyId == updateId)
                try database.run(updateElement.update(dynastyId <- info.dynastyId, dynastyName <- info.dynastyName, dynastyInfo <- info.dynastyInfo))
            case.poet:
                updateId = info.poetId
                let updateElement = poetTable.filter(poetId == updateId)
                try database.run(updateElement.update(poetId <- info.poetId, poetName <- info.poetName, dynastyId <- info.dynastyId, poetInfo <- info.poetInfo))
            case .poem:
                updateId = info.poemId
                let updateElement = poemTable.filter(poemId == updateId)
                try database.run(updateElement.update(poemId <- info.poemId, poemName <- info.poemName, poetId <- info.poetId, dynastyId <- info.dynastyId, poemBody <- info.poemBody))
            case .userPoem:
                updateId = info.userPoemId
                let updateElement = userPoemTable.filter(userPoemId == updateId)
                try database.run(updateElement.update(userPoemId <- info.userPoemId, userPoemName <- info.userPoemName, userPoemDate <- info.userPoemDate, userPoemDynasty <- info.userPoemDynasty, userPoemBody <- info.userPoemBody, userPoemImageData <- info.userPoemImageData))
            }
            readData()
            completion?()
        } catch {
            debugPrint(error)
        }
    }
    
    /// 删除元素
    class public func deleteElement(info: DBInfo, completion: (() -> Void)? = nil) {
        do {
            var deleteId: String = ""
            switch info.tableType {
            case .dynasty:
                deleteId = info.dynastyId
                let deleteElement = dynastyTable.filter(dynastyId == deleteId)
                try database.run(deleteElement.delete())
            case.poet:
                deleteId = info.poetId
                let deleteElement = poetTable.filter(poetId == deleteId)
                try database.run(deleteElement.delete())
            case .poem:
                deleteId = info.poemId
                let deleteElement = poemTable.filter(poemId == deleteId)
                try database.run(deleteElement.delete())
            case .userPoem:
                deleteId = info.userPoemId
                let deleteElement = userPoemTable.filter(userPoemId == deleteId)
                try database.run(deleteElement.delete())
            }
            completion?()
        } catch {
            debugPrint(error)
        }
    }
    
    /// 清空数据库（慎用）
    class public func deleteAll(completion: (() -> Void)? = nil) {
        let info = DBInfo()
        // 遍历所有类型
        for type in TableType.allCases {
            info.tableType = type
            deleteAllWithTable(info: info)
        }
        completion?()
    }
    
    /// 清空表（慎用）
    class public func deleteAllWithTable(info: DBInfo, completion: (() -> Void)? = nil) {
        do {
            if let db = PoeticTimeDao.database {
                var delete: Delete?
                switch info.tableType {
                case .dynasty:
                    delete = dynastyTable.delete()
                case .poem:
                    delete = poemTable.delete()
                case .poet:
                    delete = poetTable.delete()
                case .userPoem:
                    delete = userPoemTable.delete()
                }
                guard let delete = delete else { return }
                try db.run(delete)
            }
            completion?()
        } catch {
            debugPrint(error)
        }
    }
}
