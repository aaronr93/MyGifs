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
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        super.willBecomeActive(with: conversation)
        
        // Present the view controller appropriate for the conversation and presentation style.
        presentViewController(for: conversation, with: presentationStyle)
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
        
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        
    }
    
    // MARK: Child view controller presentation
    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        // Remove any child view controllers that have been presented.
        removeAllChildViewControllers()
        
        //if presentationStyle == .compact {
            // Compact view
            
        //} else {
            // Full-page view
            let mainFeedController = GfyCollectionNodeController()
            mainFeedController.delegate = self
            addChildViewController(mainFeedController)
            mainFeedController.view.frame = view.bounds
            mainFeedController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(mainFeedController.view)
            mainFeedController.didMove(toParentViewController: self)
        //}
        
    }
    
    // MARK: Convenience
    
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
        switch (menuItem) {
        case .Gfycat:
            
            break
        case .Imgur:
            
            break
        case .Settings:
            
            break
        default:
            break
        }
    }
}

