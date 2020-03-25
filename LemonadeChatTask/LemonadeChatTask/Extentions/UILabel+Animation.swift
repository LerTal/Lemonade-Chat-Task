//
//  UILabel+Animation.swift
//  LemonadeChatTask
//
//  Created by Tal Lerman on 25/03/2020.
//  Copyright © 2020 Tal Lerman. All rights reserved.
//

import UIKit


extension UILabel {
    
    func animate(newText: String, characterDelay: TimeInterval) {
        DispatchQueue.main.async {
            self.text = ""
            for (index, character) in newText.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(index)) {
                    self.text?.append(character)
                }
            }
        }
    }
    
}
