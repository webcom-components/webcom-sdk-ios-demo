//
//  WebcomManager.swift
//  Webcom-Demo
//
//  Created by Florent Maitre on 03/03/2016.
//  Copyright © 2016 Orange. All rights reserved.
//

import Foundation
import Webcom

/// Singleton used to access Webcom services
class WebcomManager: NSObject, AuthenticationViewControllerDelegate
{
    // MARK: - Private properties
    
    // Singleton
    private static let sharedInstance = WebcomManager()
    
    // Webcom base URL path
    private let baseURLPath = "https://io.datasync.orange.com/base/chatdemo"
    
    // Webcom chat demo base
    private let webcomBase: WCWebcom!
    
    // Webcom chat demo users
    private let webcomUsers: WCWebcom!
    
    // MARK: - Overriden methods
    
    override init()
    {
        webcomBase = WCWebcom(URL: "\(baseURLPath)")
        webcomUsers = WCWebcom(URL: "\(baseURLPath)/users")
        
        super.init()
    }
    
    // MARK: - Public methods
    
    /**
    Returns WebcomManager shared instance
    
    - returns: Singleton
    */
    class func sharedManager() -> WebcomManager
    {
        return WebcomManager.sharedInstance
    }
    
    /**
     Sends message
     
     - parameter text:                Text
     - parameter userIdentifier:      User identifier
     - parameter recipientIdentifier: Recipient identifier to send message in a private chat room, or nil to send message in general chat room
     */
    func sendMessageWithText(text: String, fromUser userIdentifier: String, toRecipient recipientIdentifier: String?)
    {
        let webcomChat = webcomChatWithUser(userIdentifier, recipient: recipientIdentifier)
        let message = ["senderIdentifier": userIdentifier, "text": text]
        webcomChat?.push(message)
    }
    
    /**
     Retrieve messages between a user and a recipient
     The handler is called when retrieving existing messages as well as when a new message is sent by the recipient
     
     - parameter handler:             Handler
     - parameter userIdentifier:      User identifier
     - parameter recipientIdentifier: Recipient identifier to retrieve messages in a private chat room, or nil to retrieve messages in general chat room
     */
    func registerHandler(handler: ((senderIdentifier: String, text: String) -> Void), forMessagesBetweenUser userIdentifier: String, andRecipient recipientIdentifier: String?)
    {
        let webcomChat = webcomChatWithUser(userIdentifier, recipient: recipientIdentifier)
        webcomChat?.onEventType(.ChildAdded , withCallback:
            {
                (snapshot: WCDataSnapshot?, prevKey: String?) -> Void in
                
                if let message = snapshot?.value as? [String: AnyObject],
                    let senderIdentifier = message["senderIdentifier"] as? String,
                    let text = message["text"] as? String
                {
                    handler(senderIdentifier: senderIdentifier, text: text)
                }
        })
    }
    
    /**
     Unregisters message retrieval handlers for a specific user and recipient
     
     - parameter userIdentifier:      User identifier
     - parameter recipientIdentifier: Recipient identifier for a private chat room, or nil for general chat room
     */
    func unregisterHandlersForMessagesBetweenUser(userIdentifier: String, andRecipient recipientIdentifier: String?)
    {
        let webcomChat = webcomChatWithUser(userIdentifier, recipient: recipientIdentifier)
        webcomChat?.offEventType(.ChildAdded)
    }
    
    /**
     Adds a new user
     
     - parameter identifier: User identifier
     */
    func addUserWithIdentifier(identifier: String)
    {
        if identifier.characters.count > 0
        {
            if let path = identifier.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.webcomURLPathAllowedCharacterSet())
            {
                let webcomUser = webcomUsers?.child(path)
                webcomUser?.set(["identifier": identifier])
            }
        }
    }
    
    /**
     Retrieve users
     The handler is called when retrieving existing users as well as when a new user is added
     
     - parameter handler: Handler
     */
    func registerHandlerForUsers(handler: ((userIdentifier: String) -> Void))
    {
        webcomUsers?.onEventType(.ChildAdded, withCallback:
            {
                (snapshot: WCDataSnapshot?, prevKey: String?) -> Void in
                
                if let user = snapshot?.value as? [String: AnyObject],
                    let userIdentifier = user["identifier"] as? String
                {
                    handler(userIdentifier: userIdentifier)
                }
        })
    }
    
    /**
     Unregisters users handlers
     */
    func unregisterHandlersForUsers()
    {
        webcomUsers?.offEventType(.ChildAdded)
    }
    
    /**
     Disconnects user from Webcom services
     */
    func disconnect()
    {
        webcomBase?.logout()
    }
    
    /**
     Tries to resume Webcom connection
     */
    func resumeConnection()
    {
        webcomBase?.resumeWithCallback(
            {
                (error: NSError?, authInfo: WCAuthInfo?) -> Void in
                
                // Connection could not be resumed
                if authInfo == nil
                {
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    let presentedViewController = appDelegate.messagesViewController.presentedViewController as? AuthenticationViewController
                    
                    // Show authentication screen if not already displayed
                    if presentedViewController == nil
                    {
                        let authenticationViewController = AuthenticationViewController()
                        authenticationViewController.delegate = self
                        appDelegate.messagesViewController.presentViewController(authenticationViewController, animated: true, completion: nil)
                    }
                }
                else
                {
                    let email = authInfo?.email ?? ""
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.messagesViewController.senderId = email
                    appDelegate.messagesViewController.senderDisplayName = email
                }
        })
    }
    
    // MARK: - Private methods
    
    /**
    Returns Webcom node for a given user and recipient
    
    - parameter userIdentifier:      User identifier
    - parameter recipientIdentifier: Identifier of recipient for a private chat room, nil for general chat room
    
    - returns: Webcom node
    */
    private func webcomChatWithUser(userIdentifier: String, recipient recipientIdentifier: String?) -> WCWebcom?
    {
        var webcomChat: WCWebcom?
        let userIdentifierLength = userIdentifier.characters.count ?? 0
        let recipientIdentifierLength = recipientIdentifier?.characters.count ?? 0
        
        // Private chat room
        if userIdentifierLength > 0 && recipientIdentifierLength > 0
        {
            let privateChatPath = userIdentifier.compare(recipientIdentifier!) == .OrderedAscending ? "\(userIdentifier)AND\(recipientIdentifier!)" : "\(recipientIdentifier!)AND\(userIdentifier)"
            
            if let path = privateChatPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.webcomURLPathAllowedCharacterSet())
            {
                webcomChat = WCWebcom(URL: "\(baseURLPath)/chats")?.child(path)
            }
        }
        // General chat room
        else if userIdentifierLength > 0
        {
            webcomChat = WCWebcom(URL: "\(baseURLPath)/chats/general")
        }
        
        return webcomChat
    }
    
    // MARK: - AuthenticationViewControllerDelegate methods
    
    func authenticationViewController(authenticationViewController: AuthenticationViewController, didCompleteLoginWithEmail email: String, password: String)
    {
        authenticationViewController.loading = true
        
        // Authenticate
        webcomBase?.authWithMail(email, andPassword: password, andRememberMe: false, onComplete:
            {
                (error: NSError?, authInfo: WCAuthInfo?) -> Void in
                
                if authInfo != nil
                {
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.messagesViewController.senderId = email
                    appDelegate.messagesViewController.senderDisplayName = email
                    authenticationViewController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
                else
                {
                    authenticationViewController.loading = false
                    authenticationViewController.showErrorMessage(NSLocalizedString("AuthenticationLoginErrorMessageKey", comment: ""))
                }
        })
    }
    
    func authenticationViewController(authenticationViewController: AuthenticationViewController, didCompleteSignUpWithEmail email: String, password: String)
    {
        authenticationViewController.loading = true
        
        // Create user
        webcomBase?.createUser(email, withPassword: password, onComplete:
            {
                (error: NSError?, authInfo: WCAuthInfo?) -> Void in
                
                if error == nil
                {
                    self.addUserWithIdentifier(email)
                    
                    // Authenticate
                    self.webcomBase?.authWithMail(email, andPassword: password, andRememberMe: false, onComplete:
                        {
                            (error: NSError?, authInfo: WCAuthInfo?) -> Void in
                            
                            if authInfo != nil
                            {
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.messagesViewController.senderId = email
                                appDelegate.messagesViewController.senderDisplayName = email
                                authenticationViewController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                            }
                            else
                            {
                                authenticationViewController.loading = false
                                authenticationViewController.showErrorMessage(NSLocalizedString("AuthenticationLoginErrorMessageKey", comment: ""))
                            }
                    })
                }
                else
                {
                    authenticationViewController.loading = false
                    authenticationViewController.showErrorMessage(NSLocalizedString("AuthenticationSignUpErrorMessageKey", comment: ""))
                }
        })
    }
}
