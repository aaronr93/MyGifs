//
//  MessagesViewController.swift
//  MyGifsMessages
//
//  Created by Aaron Rosenberger on 1/23/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import UIKit
import MyGifsKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    var MyGifsNavController: UINavigationController?
    var activeMenuItem: MenuItem?
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        super.willBecomeActive(with: conversation)
        
        // Present the view controller appropriate for the conversation and presentation style.
        presentViewController(with: presentationStyle)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        presentViewController(with: presentationStyle)
    }
    
    // MARK: Child view controller presentation
    
    private func presentViewController(with presentationStyle: MSMessagesAppPresentationStyle) {
        // Remove any child view controllers that have been presented.
        removeAllChildViewControllers()
        
        if presentationStyle == .compact {
            // Compact view
            presentMenu()
        } else {
            // Full-page view
            presentExpandedView()
        }
        
    }
    
    // MARK: Convenience
    
    private func presentMenu() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        let compactMenu = CompactMenuCollectionViewController(collectionViewLayout: layout)
        compactMenu.delegate = self
        addChildViewController(compactMenu)
        compactMenu.view.bounds = view.bounds
        compactMenu.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(compactMenu.view)
        compactMenu.didMove(toParentViewController: self)
    }
    
    private func presentExpandedView() {
        guard let menuItem = activeMenuItem else { return }
        var expandedViewController: UIViewController?
        switch (menuItem) {
        case .Gfycat:
            expandedViewController = GfyCollectionNodeController()
            if let expandedVC = expandedViewController as? GfyCollectionNodeController {
                expandedVC.delegate = self
            }
            break
        case .Imgur:
            break
        case .Settings:
            break
        }
        if let expandedViewController = expandedViewController {
            addChildViewController(expandedViewController)
            expandedViewController.view.frame = view.bounds
            expandedViewController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(expandedViewController.view)
            expandedViewController.didMove(toParentViewController: self)
        }
    }
    
    private func removeAllChildViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }

}

extension MessagesViewController: GfyCollectionDelegate {
    func didTap(_ gifUrlString: String) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        conversation.insertText(gifUrlString, completionHandler: nil)
        dismiss()
    }
}

extension MessagesViewController: CompactMenuDelegate {
    func didTap(_ menuItem: MenuItem) {
        activeMenuItem = menuItem
        requestPresentationStyle(.expanded)
    }
}

