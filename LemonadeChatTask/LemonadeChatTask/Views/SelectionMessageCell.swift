//
//  SelectionMessageCell.swift
//  LemonadeChatTask
//
//  Created by Tal Lerman on 24/03/2020.
//  Copyright © 2020 Tal Lerman. All rights reserved.
//

import UIKit


class SelectionMessageCell: UICollectionViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var label: UILabel!
    
    
    // MARK: - View Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 15
        backgroundColor = .lightGray
    }
}
