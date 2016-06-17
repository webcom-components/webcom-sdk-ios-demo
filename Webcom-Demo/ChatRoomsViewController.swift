//
//  UsersViewController.swift
//  Webcom-Demo
//
//  Created by Florent Maitre on 26/02/2016.
//  Copyright © 2016 Orange. All rights reserved.
//

import UIKit

/// Protocol implemented by the delegate of a ChatRoomsViewController object
protocol ChatRoomsViewControllerDelegate: class
{
    /**
     Informs the delegate that the user selected a chat room
     
     - parameter chatRoomsViewController: ChatRoomsViewController object informing the delegate
     - parameter recipientIdentifier:     Recipient identifier for a private chat room, nil for general chatroom
     */
    func chatRoomsViewController(chatRoomsViewController: ChatRoomsViewController, didSelectChatRoomWithRecipient recipientIdentifier: String?)
    
    /**
     Informs the delegate that the user cancelled the chat room selection
     
     - parameter chatRoomsViewController: ChatRoomsViewController object informing the delegate
     */
    func chatRoomsViewControllerDidCancel(chatRoomsViewController: ChatRoomsViewController)
}

/// Controller managing a chat room selection screen
class ChatRoomsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: - Public properties
    
    // Delegate
    weak var delegate: ChatRoomsViewControllerDelegate?
    
    // MARK: - Private properties
    
    // List of user identifiers to be displayed in the private chat room section
    private var userIndentifiers = [String]()
    
    // Table view
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    // Cell identifier
    private let cellIdentifier = "cellIdentifier"
    
    // MARK: - Overriden methods
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.title = NSLocalizedString("ChatRoomsTitleKey", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(ChatRoomsViewController.doneButtonClicked))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(tableView)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        userIndentifiers.removeAll()
        
        // Retrieve users
        // The handler is called when retrieving existing users and when a new user is created
        WebcomManager.sharedManager().registerHandlerForUsers
            {
                (userIdentifier: String) -> Void in
                
                self.userIndentifiers.append(userIdentifier)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.userIndentifiers.count - 1, inSection: 1)], withRowAnimation: .Automatic)
        }
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        // Unregister handler
        WebcomManager.sharedManager().unregisterHandlersForUsers()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
        let edgeInsets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        tableView.scrollIndicatorInsets = edgeInsets
        
        // Fixes a bug where offset is not properly set when changing inset
        let oldTopContentInset = tableView.contentInset.top
        let oldContentOffset = tableView.contentOffset
        tableView.contentInset = edgeInsets
        tableView.contentOffset = CGPoint(x: oldContentOffset.x, y: oldContentOffset.y + oldTopContentInset - edgeInsets.top);
    }
    
    // MARK: - Private methods
    
    /**
    Done button callback
    */
    func doneButtonClicked()
    {
        delegate?.chatRoomsViewControllerDidCancel(self)
    }
    
    // MARK: - UITableViewDataSource methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return section == 0 ? 1 : userIndentifiers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = indexPath.section == 0 ? NSLocalizedString("GeneralChatRoomTitleKey", comment: "") : userIndentifiers[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        var title: String?
        
        if section == 0
        {
            title = NSLocalizedString("PublicChatRoomsTitleKey", comment: "")
        }
        else if userIndentifiers.count > 0
        {
            title = NSLocalizedString("PrivateChatRoomsTitleKey", comment: "")
        }
        
        return title
    }
    
    // MARK: - UITableViewDelegate methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let recipientIdentifier: String? = indexPath.section == 0 ? nil : userIndentifiers[indexPath.row]
        delegate?.chatRoomsViewController(self, didSelectChatRoomWithRecipient: recipientIdentifier)
    }
}
