//
//  AppDelegate.swift
//  Webcom-Demo
//
//  Created by Florent Maitre on 23/02/2016.
//  Copyright © 2016 Orange. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    // MARK: - Inherited properties
    
    var window: UIWindow?
    
    // Main view controller displaying messages
    let messagesViewController = MessagesViewController()
    
    // MARK: - UIApplicationDelegate methods
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.tintColor = UIColor(red: 241.0 / 255.0, green: 110.0 / 255.0, blue: 0.0, alpha: 1.0)
        window?.rootViewController = UINavigationController(rootViewController: messagesViewController)
        window?.makeKeyAndVisible()
        
        // Try to resume Webcom connection
        WebcomManager.sharedManager().resumeConnection()
        
        return true
    }
}
