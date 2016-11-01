//
//  AppDelegate.swift
//  MCalendar
//
//  Created by Luvina on 9/28/16.
//  Copyright © 2016 Luvina. All rights reserved.
//

import UIKit
import CoreData
import MagicalRecord
import UserNotifications
import GoogleMaps
//import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var strDeviceToken: String = ""

    // MARK: - App life cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NSLog("set up MR")
        MagicalRecord.setupAutoMigratingCoreDataStack()
        
        NSLog("registed for notification")
        registerForRemoteNotification()
        
        NSLog("registed for google maps")
        // register Google Maps & Places
        GMSServices.provideAPIKey("AIzaSyCmlZGfwRyAXeHP9p-B4UKAmr85RUvjW1M")
        
        NSLog("didFinishLaunching")
        //GMSPlacesClient.provideAPIKey("AIzaSyCmlZGfwRyAXeHP9p-B4UKAmr85RUvjW1M")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data
    // Core data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MCalendar")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        print("NSPersistentContainer///////////////////////////////////////////////")
        return container
    }()

    // Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("saveContext///////////////////////////////////////////////")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Notification
    // register notification
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { (granted, error) in
                if error == nil {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.addCategory()
                }
            })
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
            self.addCategory()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let chars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var token = ""
        
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [chars[i]])
        }
        
        print("device token = ", deviceToken)
        self.strDeviceToken = token
    }
    
    // called when a notification is delivered to a foreground app
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User info = ", notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    // called to let your app know which action was selected by the user for a given notification
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User info = ", response.notification.request.content.userInfo)
        completionHandler()
    }

    // Add category
    func addCategory() {
        
        // Add action
        //let cancelAction = UNNotificationAction(identifier: "cancel", title: "Cancel", options: [.foreground])
        
        let category = UNNotificationCategory(identifier: "MCalendarNotification", actions: [/*cancelAction*/], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
    }
}

