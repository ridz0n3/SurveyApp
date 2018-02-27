//
//  AppDelegate.swift
//  SurveyApp
//
//  Created by ridzuan othman on 31/12/2017.
//  Copyright © 2017 ridzuan othman. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import RealmSwift
import BoltsSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        configureRealm()
        IQKeyboardManager.sharedManager().enable = true
        
        let navigationBarAppearace = UINavigationBar.appearance()
        
        let font = UIFont(name: "GothamRounded-Light", size: 17)
        
        if let font = font {
            navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor : UIColor.white];
        }else{
            navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white];
        }
        
        navigationBarAppearace.barTintColor = hexStringToUIColor(hex: "#191919")
        navigationBarAppearace.isTranslucent = false
       
        if isConnectedToNetwork(){
            Api.getToken().continueWith { (task) -> Any? in
                if task.succeed {
                    
                    if User.current.isLogin{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let TabSetupVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                        self.window!.rootViewController = TabSetupVC
                    }else{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let TabSetupVC = storyboard.instantiateViewController(withIdentifier: "LoginNav")
                        self.window!.rootViewController = TabSetupVC
                    }
                    
                }else {
                    task.showError()
                }
                return nil
            }
        }else{
            if User.current.isLogin{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let TabSetupVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                self.window!.rootViewController = TabSetupVC
            }else{
                showErrorMessage("You have no internet connection.")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let TabSetupVC = storyboard.instantiateViewController(withIdentifier: "LoginNav")
                self.window!.rootViewController = TabSetupVC
            }
        }
        
        return true
    }
    
    private func configureRealm() {
        
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = 1
        config.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = config
        
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
    }


}
