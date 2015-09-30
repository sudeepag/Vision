//
//  AppDelegate.swift
//  HackVision
//
//  Created by Sudeep Agarwal on 9/19/15.
//  Copyright © 2015 Sudeep Agarwal. All rights reserved.
//

import UIKit
import AVFoundation
import AFNetworking
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        obtainAuthToken()
        WordManager.sharedManager
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func obtainAuthToken() {
        let manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"))
        let params = ["client_id":"vision",
            "client_secret":"tqz9KE1RsLiFzf9tCrkL3a1U/qHKxSwQ26FqjdkrpU0=",
            "scope": "http://api.microsofttranslator.com",
            "grant_type": "client_credentials"]
        manager.POST("", parameters: params, success: { (res, obj) -> Void in
            var json = JSON(obj)
            NSUserDefaults.standardUserDefaults().setObject(json["access_token"].stringValue, forKey: "translateToken")
            NSUserDefaults.standardUserDefaults().synchronize()
            // handle token
            }) { (req, err) -> Void in
                
                print("err \(req) and \(err)")
                
        }
        
    }

}

