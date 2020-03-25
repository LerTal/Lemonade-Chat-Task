//
//  LocalServer.swift
//  LemonadeChatTask
//
//  Created by Tal Lerman on 24/03/2020.
//  Copyright © 2020 Tal Lerman. All rights reserved.
//

import Foundation


class LocalServer {
    
    // MARK: - Properties
    private var state:    ServerState = .step1
    private var userName: String?
    
    
    // MARK: - Public Functions
    
    func start() -> Data? {
        return stepAction()
    }
    
    func userAnswer(jsonData: Data) -> Data? {
        return stepAction(jsonData: jsonData)
    }
    
    // MARK: - Private Functions
    
    private func stepAction(jsonData: Data? = nil) -> Data? {
        
        switch state {
        case .step2:
            if (jsonData != nil) {
                self.userName = self.textAnswer(jsonData!)
            }
        case .step5:
            if (jsonData != nil) {
                let userAnswer = self.textAnswer(jsonData!)
                if (userAnswer == "RESTART") {
                    self.state = .step1
                }
            }
        default:
            break
        }
        
        var res: Data? = nil
        let jsonDataToSend = createJsonData(for: state)
        
        switch jsonDataToSend {
        case .success(let data):
            res = data
            self.state = state.nextServerState()
            
        case .failure(let err):
            print("failure --> \(err)")
        }
        
        return res
    }
    
    private func textAnswer(_ jsonUserMessageData: Data) -> String {
        let res: String
        do {
            let decoder = JSONDecoder()
            let userMessage = try decoder.decode(UserMessage.self, from: jsonUserMessageData)
            res = userMessage.text
        }
        catch {
            res = "---"
        }
        return res
    }
    
    private func createJsonData(for serverState: ServerState) -> Result<Data, Error> {
        let message: [BotMessage]
        switch state {
        case .step2:    message = serverState.message(userName: userName)
        default:        message = serverState.message()
        }
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(message)
            return .success(jsonData)
        }
        catch {
            return .failure(error)
        }
    }
    
}



// MARK: - ServerState
internal enum ServerState {
    case step1, step2, step3, step4, step5, finished
    
    
    func nextServerState() -> ServerState {
        let res: ServerState
        switch self {
        case .step1:    res = .step2
        case .step2:    res = .step3
        case .step3:    res = .step4
        case .step4:    res = .step5
        case .step5,
             .finished: res = .finished
        }
        return res
    }
    
    func message(userName: String? = nil) -> [BotMessage] {
        let res: [BotMessage]
        
        switch self {
        case .step1:
            res = [BotMessage(id: UUID(),
                           text: "Hello, I am Tal!",
                           answerType: .non),
                   BotMessage(id: UUID(),
                           text: "What is your name?",
                           answerType: .text)]
        case .step2:
            res = [BotMessage(id: UUID(),
                              text: "Nice to meet you \(userName ?? "[user name]") :)",
                           answerType: .non),
                   BotMessage(id: UUID(),
                           text: "What is your phone number?",
                           answerType: .phone)]
        case .step3:
            res = [BotMessage(id: UUID(),
                           text: "Do you agree to our terms of service?",
                           answerType: .select,
                           potentialAnswers: ["NO", "YES"])]
        case .step4:
            res = [BotMessage(id: UUID(),
                           text: "Thanks!",
                           answerType: .non),
                   BotMessage(id: UUID(),
                           text: "This is the last step!",
                           answerType: .non),
                   BotMessage(id: UUID(),
                           text: "What do you want to do now?",
                           answerType: .select,
                           potentialAnswers: ["RESTART", "EXIT"])]
        case .step5:
            res = [BotMessage(id: UUID(),
                           text: "Bye Bye!",
                           answerType: .finished)]
        case .finished:
            res = [BotMessage]()
        }
        
        return res
    }
}
