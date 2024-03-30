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
}

// 数据库参数
public class DBInfo {
    var poetId = ""
    var poetName = ""
    var poemId = ""
    var poemName = ""
    var poemBody = ""
    var dynastyId = ""
    var dynastyName = ""
    var dynastyInfo = ""
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
    init(poetId: String, poetName: String, dynastyId: String) {
        self.poetId = poetId
        self.poetName = poetName
        self.dynastyId = dynastyId
        self.tableType = .poet
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
                try db.transaction {
                    for row in rows {
                        let components = row.components(separatedBy: ",,")
                        if components.count == 3 {
                            let string1 = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string2 = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                            let string3 = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
                            try db.run(poetTable.insert(poetId <- string1, poetName <- string2, dynastyId <- string3))
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
    class public func initDB() {
        // 建立连接
        PoeticTimeDao.connectDB()
        // 建表
        PoeticTimeDao.createTableIfNotExist()
        deleteAll()
        initDynastyDB()
        initPoetDB()
        initPoemDB()
    }
    
    /// 打印表数据
    class public func printTable(info: DBInfo) {
        do {
            if let db = PoeticTimeDao.database {
                switch info.tableType {
                case .dynasty:
                    for dynasty in try db.prepare(dynastyTable) {
                        print("dynastyId: \(dynasty[dynastyId]), dynastyName: \(dynasty[dynastyName]), dynastyInfo: \(dynasty[dynastyInfo])")
                    }
                case .poem:
                    for poem in try db.prepare(poemTable) {
                        print("poemId: \(poem[poemId]), poemName: \(poem[poemName]), poetId: \(poem[poetId]), dynastyId: \(poem[dynastyId]), poemBody: \(poem[poemBody])")
                    }
                case .poet:
                    for poet in try db.prepare(poetTable) {
                        print("poetId: \(poet[poetId]), poetName: \(poet[poetName]), dynastyId: \(poet[dynastyId])")
                    }
                }
            }
        } catch {
            debugPrint(error)
        }
    }
    
    /// 读取数据到内存
    class public func readData() {
        do {
            if let db = PoeticTimeDao.database {
                for dynasty in try db.prepare(dynastyTable) {
                    let dynastyElement = Dynasty(dynastyId: dynasty[dynastyId], dynastyName: dynasty[dynastyName], dynastyInfo: dynasty[dynastyInfo])
                    dynastyData.append(dynastyElement)
                }
                for poem in try db.prepare(poemTable) {
                    let poemElement = Poem(poemId: poem[poemId], poemName: poem[poemName], poetId: poem[poetId], dynastyId: poem[dynastyId], poemBody: poem[poemBody])
                    poemData.append(poemElement)
                }
                for poet in try db.prepare(poetTable) {
                    let poetElement = Poet(poetId: poet[poetId], poetName: poet[poetName], dynastyId: poet[dynastyId])
                    poetData.append(poetElement)
                }
            }
        } catch {
            debugPrint(error)
        }
    }
    
    /// 插入元素
    class public func insertElement(info: DBInfo) {
        if let db = PoeticTimeDao.database {
            do {
                switch info.tableType {
                case .dynasty:
                    try db.run(dynastyTable.insert(dynastyId <- info.dynastyId, dynastyName <- info.dynastyName, dynastyInfo <- info.dynastyInfo))
                case .poet:
                    try db.run(poetTable.insert(poetId <- info.poetId, poetName <- info.poetName, dynastyId <- info.dynastyId))
                case .poem:
                    try db.run(poemTable.insert(poemId <- info.poemId, poemName <- info.poemName, poetId <- info.poetId, dynastyId <- info.dynastyId, poemBody <- info.poemBody))
                }
            } catch {
                debugPrint(error)
            }
        }
    }
    
    /// 更新元素(必须全部字段传入）
    class public func updateElement(info: DBInfo) {
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
                try database.run(updateElement.update(poetId <- info.poetId, poetName <- info.poetName, dynastyId <- info.dynastyId))
            case .poem:
                updateId = info.poemId
                let updateElement = poemTable.filter(poemId == updateId)
                try database.run(updateElement.update(poemId <- info.poemId, poemName <- info.poemName, poetId <- info.poetId, dynastyId <- info.dynastyId, poemBody <- info.poemBody))
            }
        } catch {
            debugPrint(error)
        }
    }
    
    /// 删除元素
    class public func deleteElement(info: DBInfo) {
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
            }
        } catch {
            debugPrint(error)
            print("123123")
        }
    }
    
    /// 清空数据库（慎用）
    class public func deleteAll() {
        let info = DBInfo()
        // 遍历所有类型
        for type in TableType.allCases {
            info.tableType = type
            deleteAllWithTable(info: info)
        }
    }
    
    /// 清空表（慎用）
    class public func deleteAllWithTable(info: DBInfo) {
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
                }
                guard let delete = delete else { return }
                try db.run(delete)
            }
        } catch {
            debugPrint(error)
        }
    }
}
