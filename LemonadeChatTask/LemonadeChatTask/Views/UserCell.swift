//
//  UserCell.swift
//  LemonadeChatTask
//
//  Created by Tal Lerman on 24/03/2020.
//  Copyright © 2020 Tal Lerman. All rights reserved.
//

import UIKit


class UserCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    static let leftChatCellConstraintValue  = CGFloat(120)
    static let rightChatCellConstraintValue = CGFloat(20)
    static let topChatCellConstraintValue   = CGFloat(15)
    
    // MARK: - IBOutlet
    @IBOutlet weak var answer:                  UILabel!
    @IBOutlet weak var leftChatCellConstraint:  NSLayoutConstraint!
    @IBOutlet weak var rightChatCellConstraint: NSLayoutConstraint!
    @IBOutlet weak var topChatCellConstraint:   NSLayoutConstraint!
    
    
    // MARK: - View Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        answer.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftChatCellConstraint.constant  = UserCell.leftChatCellConstraintValue
        rightChatCellConstraint.constant = UserCell.rightChatCellConstraintValue
        topChatCellConstraint.constant   = UserCell.topChatCellConstraintValue
    }
}
