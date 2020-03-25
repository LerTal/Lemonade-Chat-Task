//
//  AnswerType.swift
//  LemonadeChatTask
//
//  Created by Tal Lerman on 24/03/2020.
//  Copyright © 2020 Tal Lerman. All rights reserved.
//

import Foundation


enum AnswerType {
    case non
    case text
    case phone
    case select
    case finished   // last Bot Message
    
    
    init(typeId: Int) {
        let res: AnswerType
        switch typeId {
        case 1:     res = .text
        case 2:     res = .phone
        case 3:     res = .select
        case 4:     res = .finished
        default:    res = .non
        }
        self = res
    }
    
    func getTypeId() -> Int {
        let typeId: Int
        switch self {
        case .non:      typeId = 0
        case .text:     typeId = 1
        case .phone:    typeId = 2
        case .select:   typeId = 3
        case .finished: typeId = 4
        }
        return typeId
    }
    
}
