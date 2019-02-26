//
//  AppDelegate.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-21.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import UserNotifications
import FirebaseMessaging

import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Switcher.updateRootVC()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func messaging(_ messaging:Messaging, didReceiveRegistrationToken fromToken:String){
        let VC: LoginViewController = LoginViewController()
        let VC2: RegisterViewController = RegisterViewController()
        let token:[String:AnyObject] = [Messaging.messaging().fcmToken! : Messaging.messaging().fcmToken as AnyObject]
        if Auth.auth().currentUser?.uid != nil {
        VC.postToken(Token: token)
        VC2.postToken(Token: token)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        //Print message ID
        if let messageID = userInfo[gcmMessageIDKey]{
            print("Message ID: \(messageID)")
        }
        //Print full message
        print(userInfo)
        
        //User tapped on notification
        switch response.actionIdentifier{
        case UNNotificationDefaultActionIdentifier:
            openViewController()
            completionHandler()
            
        default: break;
        }
    }
    
    func openViewController(){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = sb.instantiateViewController(withIdentifier: "MainTabController") as! UITabBarController
    
        tabBarController.selectedViewController = tabBarController.viewControllers?[3]
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = tabBarController
        self.window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("APN Received")
        
        let state = application.applicationState
        
        switch state{
        case .inactive:
            print("inactive")
            application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
            
        case .background:
            print("background")
            application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
            
        case .active:
            print("active")
        }

    }


    func applicationWillResignActive(_ application: UIApplication) {
    
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       resetBadge()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        resetBadge()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func resetBadge(){
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func resetBadgeValue(){
        let rootViewController = self.window?.rootViewController
        if let tabBarController = rootViewController?.tabBarController{
            print("tab")
            let tabBarItem = tabBarController.tabBar.items![3]
            tabBarItem.badgeValue = ""
        }
    }

}

