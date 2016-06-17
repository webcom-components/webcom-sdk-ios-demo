//
//  AuthenticationViewController.swift
//  Webcom-Demo
//
//  Created by Florent Maitre on 29/02/2016.
//  Copyright © 2016 Orange. All rights reserved.
//

import UIKit

/// Protocol implemented by the delegate of an AuthenticationViewController object
protocol AuthenticationViewControllerDelegate: class
{
    /**
     Informs the delegate that the user completed the form to sign up
     
     - parameter authenticationViewController: AuthenticationViewController object informing the delegate
     - parameter email:                        Email
     - parameter password:                     Password
     */
    func authenticationViewController(authenticationViewController: AuthenticationViewController, didCompleteSignUpWithEmail email: String, password: String)
    
    /**
     Informs the delegate that the user completed the form to login
     
     - parameter authenticationViewController: AuthenticationViewController object informing the delegate
     - parameter email:                        Email
     - parameter password:                     Password
     */
    func authenticationViewController(authenticationViewController: AuthenticationViewController, didCompleteLoginWithEmail email: String, password: String)
}

/// Controller managing an authentication screen
class AuthenticationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AuthenticationTableHeaderViewDelegate
{
    // MARK: - Public properties
    
    // Delegate
    weak var delegate: AuthenticationViewControllerDelegate?
    
    // Configure loading state of the controller
    var loading = false
    {
        didSet
        {
            if isViewLoaded()
            {
                view.userInteractionEnabled = !loading
                
                if loading
                {
                    view.endEditing(true)
                }
            }
            
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? AuthenticationTableViewCell
            {
                if loading
                {
                    cell.activityIndicatorView.startAnimating()
                }
                else
                {
                    cell.activityIndicatorView.stopAnimating()
                }
            }
        }
    }
    
    // MARK: - Private properties
    
    // Email
    private var email = String()
    
    // Password
    private var password = String()
    
    // Table view
    private let tableView = UITableView()
    
    // Header for table view
    private let tableHeaderView = AuthenticationTableHeaderView()
    
    // Cell identifier
    private let textFieldCellIdentifier = "textFieldCellIdentifier"
    
    // Bottom inset for table view, computed when keyboard appears or disappears
    private var tableBottomInset = CGFloat(0.0)
    
    // true if user wants to sign up, false if user wants to login
    private var signUp = false
    
    // MARK: - Inherited methods
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableHeaderView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(AuthenticationTableViewCell.self, forCellReuseIdentifier: textFieldCellIdentifier)
        tableView.scrollEnabled = false
        tableView.rowHeight = 52.0
        tableView.keyboardDismissMode = .Interactive
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 30.0, bottom: 0.0, right: 30.0)
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView()
        
        // Tap gesture to remove keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthenticationViewController.handleTapGesture))
        tableView.addGestureRecognizer(tapGestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AuthenticationViewController.keyboardWillChangeFrameNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AuthenticationViewController.textFieldTextDidChangeNotification(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
        
        loading = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(tableView)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        tableView.endEditing(true)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let edgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: tableBottomInset, right: 0.0)
        tableView.contentInset = edgeInsets
        tableView.scrollIndicatorInsets = edgeInsets
        tableView.frame = view.bounds
        
        let tableHeaderSize = tableHeaderView.sizeThatFits(view.bounds.size)
        tableHeaderView.frame = CGRect(x: 0.0, y: 0.0, width: tableHeaderSize.width, height: tableHeaderSize.height).integral
        tableView.tableHeaderView = tableHeaderView
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return .LightContent
    }
    
    // MARK: - Private methods
    
    /**
    Tap gesture callback
    */
    func handleTapGesture()
    {
        tableView.endEditing(true)
    }
    
    /**
     Notification callback for text field text change
     
     - parameter notification: Notification
     */
    func textFieldTextDidChangeNotification(notification: NSNotification)
    {
        if let textField = notification.object as? UITextField
        {
            if textField.tag == 0
            {
                email = textField.text ?? ""
            }
            else if textField.tag == 1
            {
                password = textField.text ?? ""
            }
        }
    }
    
    /**
     Notification callback for keyboard frame change
     
     - parameter notification: Notification
     */
    func keyboardWillChangeFrameNotification(notification: NSNotification)
    {
        if let userInfo = notification.userInfo
        {
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
            let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
            let keyboardVisibleRect = view.convertRect(keyboardFrameEnd.CGRectValue(), fromView: nil)
            
            let intersectionFrame = CGRectIntersection(view.bounds, keyboardVisibleRect)
            
            // Update table view bottom inset
            tableBottomInset = CGRectGetHeight(intersectionFrame)
            
            let animations =
            {
                let edgeInsets = UIEdgeInsetsMake(0.0, 0.0, self.tableBottomInset, 0.0)
                self.tableView.contentInset = edgeInsets
                self.tableView.scrollIndicatorInsets = edgeInsets
            }
            
            UIView.animateWithDuration(animationDuration.doubleValue,
                delay: 0.0,
                options: .BeginFromCurrentState,
                animations: animations,
                completion: nil)
            
            // Scroll at the bottom of the table view
            let bottomContentOffset = tableView.contentSize.height - tableView.bounds.size.height + tableView.contentInset.bottom
            tableView.contentOffset = CGPoint(x: 0.0, y: max(bottomContentOffset, 0.0))
        }
    }
    
    // MARK: - Public methods
    
    /**
    Briefly shows an error message on the header
    
    - parameter errorMessage: Error message
    */
    func showErrorMessage(errorMessage: String)
    {
        tableHeaderView.showErrorMessage(errorMessage)
    }
    
    // MARK: - UITableViewDataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellIdentifier, forIndexPath: indexPath) as! AuthenticationTableViewCell
        cell.textField.delegate = self
        cell.textField.tag = indexPath.row
        
        let isEmail = indexPath.row == 0;
        
        cell.textField.placeholder = isEmail ? NSLocalizedString("AuthenticationEmailPlaceholderKey", comment: "") : NSLocalizedString("AuthenticationPasswordPlaceholderKey", comment: "")
        cell.textField.keyboardType = isEmail ? .EmailAddress : .Default
        cell.textField.text = isEmail ? email : password
        cell.textField.returnKeyType = isEmail ? .Next : .Go
        cell.textField.clearsOnInsertion = !isEmail
        cell.textField.secureTextEntry = !isEmail
        
        if indexPath.row == 1
        {
            if loading
            {
                cell.activityIndicatorView.startAnimating()
            }
            else
            {
                cell.activityIndicatorView.stopAnimating()
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AuthenticationTableViewCell
        {
            if !cell.textField.isFirstResponder()
            {
                cell.textField.becomeFirstResponder()
            }
        }
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        let nextCellIndexPath = NSIndexPath(forRow: textField.tag + 1, inSection: 0)
        
        if let cell = tableView.cellForRowAtIndexPath(nextCellIndexPath) as? AuthenticationTableViewCell
        {
            cell.textField.becomeFirstResponder()
        }
        else
        {
            if email.characters.count == 0
            {
                tableHeaderView.showErrorMessage(NSLocalizedString("AuthenticationEmptyLoginKey", comment: ""))
            }
            else if password.characters.count == 0
            {
                tableHeaderView.showErrorMessage(NSLocalizedString("AuthenticationEmptyPasswordKey", comment: ""))
            }
            else
            {
                if signUp
                {
                    delegate?.authenticationViewController(self, didCompleteSignUpWithEmail: email, password: password)
                }
                else
                {
                    delegate?.authenticationViewController(self, didCompleteLoginWithEmail: email, password: password)
                }
            }
        }
        
        return false
    }
    
    // MARK: - AuthenticationTableHeaderViewDelegate methods
    
    func authenticationTableHeaderViewDidSelectSignUpButton(authenticationTableHeaderView: AuthenticationTableHeaderView)
    {
        signUp = true
    }
    
    func authenticationTableHeaderViewDidSelectLoginButton(authenticationTableHeaderView: AuthenticationTableHeaderView)
    {
        signUp = false
    }
}
