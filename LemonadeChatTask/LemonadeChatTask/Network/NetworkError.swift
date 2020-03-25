//
//  NetworkError.swift
//  LemonadeChatTask
//
//  Created by Tal Lerman on 24/03/2020.
//  Copyright © 2020 Tal Lerman. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case EmptyDataError
    case JSONDecoderError(type: Decodable.Type, error: Error)
}
