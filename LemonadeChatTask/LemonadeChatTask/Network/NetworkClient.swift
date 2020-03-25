//
//  NetworkClient.swift
//  LemonadeChatTask
//
//  Created by Tal Lerman on 24/03/2020.
//  Copyright © 2020 Tal Lerman. All rights reserved.
//

import Foundation


class NetworkClient {
    
    // MARK: - Properties
    let localServer = LocalServer()
    
    // MARK: - Constractor
    
    static let shared: NetworkClient = {
        return NetworkClient()
    }()
    
    // MARK: - Object Life Cycle
    
    private init() {
        //...
    }
    
    // MARK: - Public Functions
    
    func start(completion: @escaping (Result<[BotMessage], NetworkError>) -> Void) {
        let jsonData = localServer.start()
        
        loadJSON(objType: [BotMessage].self, data: jsonData, completion: completion)
    }
    
    func userAnswer(_ answer: UserMessage, completion: @escaping (Result<[BotMessage], NetworkError>) -> Void) {
        do {
            let encoder = JSONEncoder()
            let jsonAnswer = try encoder.encode(answer)
            let jsonData = localServer.userAnswer(jsonData: jsonAnswer)
            
            loadJSON(objType: [BotMessage].self, data: jsonData, completion: completion)
        }
        catch {
            let err = NetworkError.JSONDecoderError(type: UserMessage.self, error: error)
            DispatchQueue.main.async { completion(Result.failure(err)) }
        }
    }
    
    // MARK: - Private Functions
    
    private func loadJSON<T: Decodable>(objType: T.Type, data: Data?, completion: @escaping (Result<T, NetworkError>) -> Void ) {
        
        let success: (T) -> Void = { obj in
            DispatchQueue.main.async { completion(Result.success(obj)) }
        }
        
        let failure: (NetworkError) -> Void = { error in
            DispatchQueue.main.async { completion(Result.failure(error)) }
        }
        
        guard let data = data else {
            failure((NetworkError.EmptyDataError))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let obj = try decoder.decode(T.self, from: data)
            success(obj)
        }
        catch {
            failure(NetworkError.JSONDecoderError(type: T.self, error: error))
        }
    }
    
}
