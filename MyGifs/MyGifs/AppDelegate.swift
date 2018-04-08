//
//  AppDelegate.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/21/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import UIKit
import MessageUI
import AVFoundation
import MyGifsKit

enum Tabs: Int {
    case Gfycat
    case Imgur
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = {
        let window = UIWindow()
        window.backgroundColor = .white
        return window
    }()
    
    lazy var TabBarController: UITabBarController = {
        return UITabBarController()
    }()
    
    lazy var GfycatNavController: UINavigationController = {
        let controller = UINavigationController()
        controller.addChildViewController(GfycatGifsController)
        return controller
    }()
    
    lazy var GfycatGifsController: GifCollectionNodeController = {
        let gfycatGifsController = GifCollectionNodeController(identifier: "aaronr93", sourceType: .GfycatUserGifs)
        gfycatGifsController.delegate = self
        return gfycatGifsController
    }()
    
    lazy var ImgurNavController: UINavigationController = {
        let controller = UINavigationController()
        controller.addChildViewController(GetImgurAlbumsController(username: "aaronr93"))
        return controller
    }()
    
    func GetImgurAlbumsController(username: String) -> AlbumCollectionNodeController {
        let imgurAlbumsController = AlbumCollectionNodeController(identifier: username, sourceType: .ImgurUserAlbums)
        imgurAlbumsController.viewTitle = "Imgur Albums"
        imgurAlbumsController.delegate = self
        return imgurAlbumsController
    }
    
    func GetImgurGifsController(albumId: String) -> GifCollectionNodeController {
        let imgurGifsController = GifCollectionNodeController(identifier: albumId, sourceType: .ImgurAlbumGifs)
        imgurGifsController.delegate = self
        return imgurGifsController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        TabBarController.setViewControllers([GfycatNavController, ImgurNavController], animated: true)
        TabBarController.selectedIndex = Tabs.Imgur.rawValue
        TabBarController.tabBar.items![0].title = "Gfycat Gifs"
        TabBarController.tabBar.items![1].title = "Imgur Albums"
        
        // UIWindow
        window?.rootViewController = TabBarController
        window?.makeKeyAndVisible()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true, with: .notifyOthersOnDeactivation)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print("Error changing audio session settings")
        }
        
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
    }
}

extension AppDelegate: CollectionDelegate {
    func didTap(_ item: SendableItem, _ action: TapAction) {
        switch action {
        case .ExpandChildren:
            if TabBarController.selectedIndex == 1, ImgurNavController.visibleViewController is AlbumCollectionNodeController {
                ImgurNavController.pushViewController(GetImgurGifsController(albumId: item.id), animated: true)
            }
            break
        case .SendTextMessage:
            sendTextMsg(item.viewableUrl.absoluteString)
        default:
            return
        }
    }
}

extension AppDelegate: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendTextMsg(_ message: String) {
        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            composeVC.body = message
            self.GfycatNavController.present(composeVC, animated: true, completion: nil)
        }
    }
}

