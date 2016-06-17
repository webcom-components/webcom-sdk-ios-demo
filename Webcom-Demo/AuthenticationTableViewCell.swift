//
//  AuthenticationTableViewCell.swift
//  Webcom-Demo
//
//  Created by Florent Maitre on 29/02/2016.
//  Copyright © 2016 Orange. All rights reserved.
//

import UIKit

/// Cell for the authentication screen
class AuthenticationTableViewCell: UITableViewCell
{
    // MARK: - Public properties
    
    // Text field
    let textField = UITextField()
    
    // Activity indicator
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    // MARK: - Inherited methods
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        textField.font = textLabel?.font
        textField.clearButtonMode = .WhileEditing
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        
        contentView.addSubview(textField)
        contentView.addSubview(activityIndicatorView)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        textField.frame = CGRect(x: separatorInset.left,
            y: 0.0,
            width: contentView.bounds.width - separatorInset.left - separatorInset.right,
            height: contentView.bounds.height).integral
        
        let activityIndicatorSize = activityIndicatorView.sizeThatFits(contentView.bounds.size)
        activityIndicatorView.frame = CGRect(x: textField.frame.maxX - activityIndicatorSize.width,
            y: (contentView.bounds.height - activityIndicatorSize.height) / 2.0,
            width: activityIndicatorSize.width,
            height: activityIndicatorSize.height).integral
    }
}
