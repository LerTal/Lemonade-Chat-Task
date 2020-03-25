//
//  Message.swift
//  LemonadeChatTask
//
//  Created by Tal Lerman on 24/03/2020.
//  Copyright © 2020 Tal Lerman. All rights reserved.
//

import Foundation


struct BotMessage: Codable {
    let id:               UUID
    let text:             String
    let answerType:       AnswerType
    let potentialAnswers: [String]?
    
    // Init
    init(id: UUID, text: String, answerType: AnswerType, potentialAnswers: [String]? = nil) {
        self.id = id
        self.text = text
        self.answerType = answerType
        self.potentialAnswers = potentialAnswers
    }
    
    // CodingKey
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case answerType
        case potentialAnswers
    }
    
    // Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        let type = try container.decode(Int.self, forKey: .answerType)
        answerType = AnswerType(typeId: type)
        potentialAnswers = try? container.decode([String].self, forKey: .potentialAnswers)
    }
    
    // Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(answerType.getTypeId(), forKey: .answerType)
        try? container.encode(potentialAnswers, forKey: .potentialAnswers)
    }
    
}
