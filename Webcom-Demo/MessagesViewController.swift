//
//  MessagesViewController.swift
//  Webcom-Demo
//
//  Created by Florent Maitre on 23/02/2016.
//  Copyright © 2016 Orange. All rights reserved.
//

import UIKit

/// View controller displaying messages
class MessagesViewController: JSQMessagesViewController, ChatRoomsViewControllerDelegate
{
    // MARK: - Private properties
    
    // Messages
    private var messages = [JSQMessage]()
    
    // Image factory for message bubbles
    // We set the default image because there is a bug in JSQMessageViewController which makes the image blurry on @2x and @3x screens
    private let messagesBubbleImageFactory = JSQMessagesBubbleImageFactory(bubbleImage: UIImage(named: "bubble_min"), capInsets: UIEdgeInsetsZero)
    
    // Identifier of recipient for a private chat room, nil for general chat room
    private var recipientIdentifier: String?
    {
        willSet
        {
            if senderId != nil
            {
                // Unregister existing handler for the previous chat room if any
                WebcomManager.sharedManager().unregisterHandlersForMessagesBetweenUser(senderId!, andRecipient: recipientIdentifier)
            }
        }
        
        didSet
        {
            reloadMessagesBetweenUser(senderId, andRecipient: recipientIdentifier)
        }
    }
    
    // MARK: - Overriden properties
    
    // User identifier
    override var senderId: String!
    {
        willSet
        {
            if senderId != nil
            {
                // Unregister existing handler for the previous chat room if any
                WebcomManager.sharedManager().unregisterHandlersForMessagesBetweenUser(senderId!, andRecipient: recipientIdentifier)
            }
        }
        
        didSet
        {
            reloadMessagesBetweenUser(senderId, andRecipient: recipientIdentifier)
        }
    }
    
    // MARK: - Overriden methods
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        senderDisplayName = ""
        senderId = ""
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "SettingsIcon"), style: .Plain, target: self, action: #selector(MessagesViewController.settingsButtonClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ListIcon"), style: .Plain, target: self, action: #selector(MessagesViewController.chatRoomsButtonClicked))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        inputToolbar?.contentView?.leftBarButtonItem = nil
        inputToolbar?.contentView?.rightBarButtonItem?.setTitleColor(UIApplication.sharedApplication().delegate?.window??.tintColor, forState: .Normal)
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!)
    {
        // Send a message using Webcom
        WebcomManager.sharedManager().sendMessageWithText(text, fromUser: senderId, toRecipient: recipientIdentifier)
        
        finishSendingMessageAnimated(true)
    }
    
    // MARK: - JSQMessagesCollectionViewDataSource methods
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let message = messages[indexPath.row]
        let outgoingBubbleColor = UIColor(red: 241.0 / 255.0, green: 110.0 / 255.0, blue: 0.0, alpha: 1.0)
        let incomingBubbleColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
        
        return message.senderId == senderId ? messagesBubbleImageFactory.outgoingMessagesBubbleImageWithColor(outgoingBubbleColor) : messagesBubbleImageFactory.incomingMessagesBubbleImageWithColor(incomingBubbleColor)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString!
    {
        let message = messages[indexPath.row]
        let displayName = message.senderDisplayName ?? ""
        
        return shouldShowMessageBubbleTopLabelAtIndexPath(indexPath) ? NSAttributedString(string: displayName) : nil
    }
    
    // MARK: - UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.row]
        
        cell.textView?.textColor = message.senderId == senderId ? UIColor.whiteColor() : UIColor.blackColor()
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        return shouldShowMessageBubbleTopLabelAtIndexPath(indexPath) ? 20.0 : 0.0
    }
    
    // MARK: - ChatRoomsViewControllerDelegate methods
    
    func chatRoomsViewController(chatRoomsViewController: ChatRoomsViewController, didSelectChatRoomWithRecipient recipientIdentifier: String?)
    {
        if recipientIdentifier != senderId
        {
            // Update recipient identifier
            self.recipientIdentifier = recipientIdentifier
        }
        
        chatRoomsViewController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func chatRoomsViewControllerDidCancel(chatRoomsViewController: ChatRoomsViewController)
    {
        chatRoomsViewController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private methods
    
    /**
    Settings button callback
    */
    func settingsButtonClicked()
    {
        // Currently the action sheet only displays a disconnect button
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let disconnectAction = UIAlertAction(title: NSLocalizedString("DisconnectButtonTitleKey", comment: ""), style: .Default)
            {
                (alertAction: UIAlertAction) -> Void in
                
                WebcomManager.sharedManager().disconnect()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CancelButtonTitleKey", comment: ""), style: .Cancel, handler: nil)
        
        alertController.addAction(disconnectAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     Chat rooms button callback
     */
    func chatRoomsButtonClicked()
    {
        let chatRoomsViewController = ChatRoomsViewController()
        chatRoomsViewController.delegate = self
        let chatRoomsNavigationController = UINavigationController(rootViewController: chatRoomsViewController)
        presentViewController(chatRoomsNavigationController, animated: true, completion: nil)
    }
    
    /**
     Indicates if a label displaying sender name should be displayed above message bubble
     
     - parameter indexPath: Index path
     
     - returns: true if label should be displayed, otherwise false
     */
    private func shouldShowMessageBubbleTopLabelAtIndexPath(indexPath: NSIndexPath) -> Bool
    {
        let message = messages[indexPath.row]
        var previousMessage: JSQMessage?
        
        if indexPath.row - 1 >= 0
        {
            previousMessage = messages[indexPath.row - 1]
        }
        
        let displayName = message.senderDisplayName ?? ""
        let previousDisplayName = previousMessage?.senderDisplayName ?? ""
        
        // Label is displayed if user is in general chat AND message sender is not user AND previous message sender is different from the current message sender
        return recipientIdentifier == nil && senderDisplayName != displayName && displayName != previousDisplayName
    }
    
    /**
     Reloads messages between a user and a recipient
     
     - parameter userIdentifier:      User identifier
     - parameter recipientIdentifier: Identifier of recipient for a private chat room, nil for general chat room
     */
    private func reloadMessagesBetweenUser(userIdentifier: String?, andRecipient recipientIdentifier: String?)
    {
        title = recipientIdentifier ?? NSLocalizedString("GeneralChatRoomTitleKey", comment: "")
        
        messages.removeAll()
        collectionView?.reloadData()
        
        if userIdentifier != nil
        {
            // Retrieve messages between the user and the recipient
            // The handler is called when retrieving existing messages and when a new message is sent in the chat room
            WebcomManager.sharedManager().registerHandler(
                {
                    (senderIdentifier: String, text: String) -> Void in
                    
                    // Insert new message
                    let message = JSQMessage(senderId: senderIdentifier, displayName: senderIdentifier, text: text)
                    self.messages.append(message)
                    
                    if userIdentifier != senderIdentifier
                    {
                        self.finishReceivingMessageAnimated(true)
                    }
                    else
                    {
                        self.finishSendingMessageAnimated(true)
                    }
                },
                forMessagesBetweenUser: userIdentifier!,
                andRecipient: recipientIdentifier)
        }
    }
}
