//
//  AuthenticationTableHeaderView.swift
//  Webcom-Demo
//
//  Created by Florent Maitre on 29/02/2016.
//  Copyright © 2016 Orange. All rights reserved.
//

import UIKit

/// Protocol implemented by the delegate of an AuthenticationTableHeaderView object
protocol AuthenticationTableHeaderViewDelegate: class
{
    /**
     Informs the delegate that the user selected the sign up button
     
     - parameter authenticationTableHeaderView: AuthenticationTableHeaderView object informing the delegate
     */
    func authenticationTableHeaderViewDidSelectSignUpButton(authenticationTableHeaderView: AuthenticationTableHeaderView)
    
    /**
     Informs the delegate that the user selected the login button
     
     - parameter authenticationTableHeaderView: AuthenticationTableHeaderView object informing the delegate
     */
    func authenticationTableHeaderViewDidSelectLoginButton(authenticationTableHeaderView: AuthenticationTableHeaderView)
}

/// Header view for the authentication screen
class AuthenticationTableHeaderView: UIView
{
    // MARK: - Public properties
    
    // Delegate
    weak var delegate: AuthenticationTableHeaderViewDelegate?
    
    // MARK: - Private properties
    
    // Title label
    private let titleLabel = UILabel()
    
    // Subtitle label
    private let subtitleLabel = UILabel()
    
    // Label displaying error message if any
    private let errorMessageLabel = UILabel()
    
    // Timer used to automatically hide error message
    private var hideErrorMessageTimer: NSTimer?
    
    // Sign up button
    private let signUpButton = UIButton(type: .System)
    
    // Login button
    private let loginButton = UIButton(type: .System)
    
    // View indicating which button is currently selected
    private let selectedButtonIndicatorView = UIView()
    
    // Button currently selected
    private var selectedButton: UIButton
    
    // MARK: - Inherited methods
    
    override init(frame: CGRect)
    {
        selectedButton = signUpButton
        
        super.init(frame: frame)
        
        // Needed because selectedButtonIndicatorView is rotated
        clipsToBounds = true
        
        backgroundColor = UIColor.blackColor()
        
        titleLabel.font = UIFont.systemFontOfSize(62.0)
        titleLabel.text = NSLocalizedString("AuthenticationTitleKey", comment: "")
        titleLabel.textColor = UIColor(red: 255.0 / 255.0, green: 121.0 / 255.0, blue: 0.0, alpha: 1.0)
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = UIFont.systemFontOfSize(20.0)
        subtitleLabel.text = NSLocalizedString("AuthenticationSubtitleKey", comment: "")
        subtitleLabel.textColor = UIColor(red: 255.0 / 255.0, green: 121.0 / 255.0, blue: 0.0, alpha: 1.0)
        subtitleLabel.numberOfLines = 0
        
        errorMessageLabel.font = UIFont.systemFontOfSize(14.0)
        errorMessageLabel.textColor = UIColor.whiteColor()
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.textAlignment = .Center
        errorMessageLabel.alpha = 0.0
        
        signUpButton.setTitle(NSLocalizedString("AuthenticationSignUpButtonTitleKey", comment: ""), forState: .Normal)
        signUpButton.titleLabel?.font = UIFont.systemFontOfSize(16.0)
        signUpButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        signUpButton.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        signUpButton.tintColor = UIColor.clearColor()
        signUpButton.addTarget(self, action: #selector(AuthenticationTableHeaderView.buttonClicked(_:)), forControlEvents: .TouchUpInside)
        
        loginButton.setTitle(NSLocalizedString("AuthenticationLoginButtonTitleKey", comment: ""), forState: .Normal)
        loginButton.titleLabel?.font = UIFont.systemFontOfSize(16.0)
        loginButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        loginButton.tintColor = UIColor.clearColor()
        loginButton.addTarget(self, action: #selector(AuthenticationTableHeaderView.buttonClicked(_:)), forControlEvents: .TouchUpInside)
        
        selectedButtonIndicatorView.backgroundColor = UIColor.whiteColor()
        selectedButtonIndicatorView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(errorMessageLabel)
        addSubview(signUpButton)
        addSubview(loginButton)
        addSubview(selectedButtonIndicatorView)
        
        selectButton(loginButton, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let titleSize = titleLabel.sizeThatFits(bounds.size)
        let subtitleSize = subtitleLabel.sizeThatFits(CGSize(width: titleSize.width, height: CGFloat.max))
        
        titleLabel.frame = CGRect(x: (bounds.width - titleSize.width) / 2.0,
            y: (bounds.height - titleSize.height - subtitleSize.height) / 2.0,
            width: titleSize.width,
            height: titleSize.height).integral
        
        subtitleLabel.frame = CGRect(x: titleLabel.frame.minX,
            y: titleLabel.frame.maxY,
            width: titleSize.width,
            height: subtitleSize.height).integral
        
        let loginSize = loginButton.sizeThatFits(bounds.size)
        loginButton.frame = CGRect(x: 0.0,
            y: bounds.height - loginSize.height - 16.0,
            width: bounds.width / 2.0,
            height: loginSize.height).integral
        
        let signUpSize = signUpButton.sizeThatFits(bounds.size)
        signUpButton.frame = CGRect(x: loginButton.frame.maxX,
            y: bounds.height - signUpSize.height - 16.0,
            width: bounds.width - loginButton.frame.maxX,
            height: signUpSize.height).integral
        
        let errorMessagePadding = UIEdgeInsets(top: 5.0, left: 15.0, bottom: 0.0, right: 15.0)
        errorMessageLabel.frame = CGRect(x: errorMessagePadding.left,
            y: subtitleLabel.frame.maxY + errorMessagePadding.top,
            width: bounds.width - errorMessagePadding.left - errorMessagePadding.right,
            height: signUpButton.frame.minY - errorMessagePadding.top - errorMessagePadding.bottom - subtitleLabel.frame.maxY).integral
        
        layoutSelectedButtonIndicatorView()
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize
    {
        return CGSize(width: size.width, height: UIScreen.mainScreen().bounds.height / 2.0)
    }
    
    // MARK: - Public methods
    
    /**
    Briefly shows an error message
    
    - parameter errorMessage: Error message
    */
    func showErrorMessage(errorMessage: String)
    {
        hideErrorMessageTimer?.invalidate()
        
        errorMessageLabel.text = errorMessage
        
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: .BeginFromCurrentState,
            animations:
            {
                () -> Void in
                
                self.errorMessageLabel.alpha = 1.0
            },
            completion:
            {
                (finished: Bool) -> Void in
                
                self.hideErrorMessageTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(AuthenticationTableHeaderView.hideErrorMessage), userInfo: nil, repeats: false)
        })
    }
    
    // MARK: - Private methods
    
    /**
    Hides the error message
    */
    func hideErrorMessage()
    {
        UIView.animateWithDuration(1.0,
            delay: 0.0,
            options: .BeginFromCurrentState,
            animations:
            {
                () -> Void in
                
                self.errorMessageLabel.alpha = 0.0
            },
            completion:nil)
    }
    
    /**
     Layout the indicator view
     */
    private func layoutSelectedButtonIndicatorView()
    {
        // We are not using the frame property because a transform is applied to the view
        selectedButtonIndicatorView.bounds = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
        selectedButtonIndicatorView.center = CGPoint(x: selectedButton.center.x, y: bounds.height)
    }
    
    /**
     Buttons callback
     
     - parameter button: Button
     */
    func buttonClicked(button: UIButton)
    {
        selectButton(button, animated: true)
    }
    
    /**
     Selects a button
     
     - parameter button:   Button to selected
     - parameter animated: true to animate, otherwise false
     */
    private func selectButton(button: UIButton, animated: Bool)
    {
        selectedButton = button
        
        signUpButton.selected = button == signUpButton
        loginButton.selected = button == loginButton
        
        if button == signUpButton
        {
            delegate?.authenticationTableHeaderViewDidSelectSignUpButton(self)
        }
        else
        {
            delegate?.authenticationTableHeaderViewDidSelectLoginButton(self)
        }
        
        let animations =
        {
            () -> Void in
            
            self.layoutSelectedButtonIndicatorView()
        }
        
        if animated
        {
            UIView.animateWithDuration(0.2,
                delay: 0.0,
                options: .BeginFromCurrentState,
                animations: animations,
                completion: nil)
        }
        else
        {
            animations()
        }
    }
}
