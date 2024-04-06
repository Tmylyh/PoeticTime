//
//  AppDelegate.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/20.
//

import UIKit
import CoreData
import SQLite

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 建立连接
        PoeticTimeDao.connectDB()
        // 第一次打开执行
        // 下面这行是测试时需要每次初始化数据才打开的
//        UserDefaults.standard.setValue(false,forKey: "isNoFirstLaunchPoeticTime")
        if !UserDefaults.standard.bool(forKey: "isNoFirstLaunchPoeticTime") && isFirstLaunch {
            // 建表、初始化诗词数据
            PoeticTimeDao.initDB()
            // 初始化用户数据
            initUserData()
            initUserInfoData()
            isFirstLaunch = false
            UserDefaults.standard.setValue(true,forKey: "isNoFirstLaunchPoeticTime")
        }
        PoeticTimeDao.readData()
        readUserInfoData()

        // 开机网络诊断
        NetworkManager.shared.networkStatusChangeHandler = { isReach in
            isReachable = isReach
            if isReachable {
                clearRequest()
            }
        }
        // 删表
//        do {
//            try PoeticTimeDao.database.run(PoeticTimeDao.userPoemTable.drop(ifExists: true))
//            print("Table dropped successfully")
//        } catch {
//            print("Error dropping table: \(error)")
//        }
        
        let info = DBInfo()
        info.tableType = .userPoem
//        info.userPoemId = "xiangtangmingyue"
//        info.userPoemName = "想唐朝明月"
//        info.userPoemBody = "今天惹唐朝明月生气了"
//        info.userPoemDynasty = "盛唐"
//        info.userPoemDate = Date().timeIntervalSince1970
//        PoeticTimeDao.insertElement(info: info)
        
        
//        let info1 = DBInfo()
//        info1.tableType = .poet
//        PoeticTimeDao.printTable(info: info)
//        let newInfo = DBInfo(dynastyId: "yuan", dynastyName: "元代", dynastyInfo: "近宋临清")
//        PoeticTimeDao.insertElement(info: newInfo)
//        let deleteInfo = DBInfo(dynastyId: "yuan", dynastyName: "", dynastyInfo: "")
//        PoeticTimeDao.deleteElement(info: deleteInfo)
//        PoeticTimeDao.printTable(info: info)
//        PoeticTimeDao.printTable(info: info1)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "PoeticTime")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

