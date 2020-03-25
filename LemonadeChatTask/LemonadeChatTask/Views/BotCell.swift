//
//  BotCell.swift
//  LemonadeChatTask
//
//  Created by Tal Lerman on 24/03/2020.
//  Copyright © 2020 Tal Lerman. All rights reserved.
//

import UIKit


class BotCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    static let leftChatCellConstraintValue  = CGFloat(20)
    static let rightChatCellConstraintValue = CGFloat(120)
    static let topChatCellConstraintValue   = CGFloat(15)
    
    // MARK: - IBOutlet
    @IBOutlet weak var message:                 UILabel!
    @IBOutlet weak var leftChatCellConstraint:  NSLayoutConstraint!
    @IBOutlet weak var rightChatCellConstraint: NSLayoutConstraint!
    @IBOutlet weak var topChatCellConstraint:   NSLayoutConstraint!
    
    
    // MARK: - View Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        message.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftChatCellConstraint.constant  = BotCell.leftChatCellConstraintValue
        rightChatCellConstraint.constant = BotCell.rightChatCellConstraintValue
        topChatCellConstraint.constant   = BotCell.topChatCellConstraintValue
    }
}
