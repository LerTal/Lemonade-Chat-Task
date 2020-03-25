//
//  ViewController.swift
//  LemonadeChatTask
//
//  Created by Tal Lerman on 24/03/2020.
//  Copyright © 2020 Tal Lerman. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var chatCollection:              UICollectionView!
    @IBOutlet weak var selectionMessageCollection:  UICollectionView!
    @IBOutlet weak var textField:                   UITextField!
    @IBOutlet weak var sentMessageButton:           UIButton!
    @IBOutlet weak var bottomView:                  UIView!
    @IBOutlet weak var bottomConstraint:            NSLayoutConstraint!
    
    // MARK: - Properties
    private var messages         = [Any]()  // Array of:  Message, Answer
    private var animatedMessages = [IndexPath]()
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChatCollectin()
        setupSelectionMessageCollection()
        setupTextField()
        setupKeyboard()
        
        startChat()
    }

    // MARK: - Setups
    
    private func setupChatCollectin() {
        chatCollection.delegate = self
        chatCollection.dataSource = self
    }
    
    private func setupSelectionMessageCollection() {
        selectionMessageCollection.delegate = self
        selectionMessageCollection.dataSource = self
    }
    
    private func setupTextField() {
        textField.delegate = self
    }
    
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    // MARK: - IBAction
   
    @IBAction func sentAnswerTapped(_ sender: UIButton) {
        guard let answerText = textField.text else { return }
        
        if (answerText.count < 3) {
            let alertController = UIAlertController(title: "Too short", message: "Please enter at list 3 digites.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        textField.text = ""
        sendAnswer(answerText)
    }
    
    // MARK: - ...
    
    private func startChat() {
        NetworkClient.shared.start { (result) in
            self.resultHandelr(result)
        }
    }
    
    fileprivate func sendAnswer(_ answerText: String) {
        let answer = UserMessage(id: UUID(), text: answerText)
        self.messages.append(answer)
        
        textField.isUserInteractionEnabled = false
        textField.resignFirstResponder()
        bottomView.isHidden = true
        
        chatCollection.reloadData()
        chatCollection.layoutIfNeeded()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            NetworkClient.shared.userAnswer(answer) { (result) in
                self.resultHandelr(result)
            }
        }
        
    }
    
    private func resultHandelr(_ result: Result<[BotMessage], NetworkError>) {
        switch result {
        case .success(let messages):
            
            let operationQueue = OperationQueue()
            operationQueue.maxConcurrentOperationCount = 1
            
            for message in messages {
                operationQueue.addOperation {
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.chatCollection.reloadData()
                        self.chatCollection.layoutIfNeeded()
                        let lastItemIndexPath = IndexPath(row: (self.messages.count - 1), section: 0)
                        self.chatCollection.scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
                    }
                    
                    sleep( UInt32( Double(message.text.count) * 0.15) )
                    
                    DispatchQueue.main.async {
                        self.updateUI(for: message)
                    }
                }
            }
            
        case .failure(let error):
            print("failure --> \(error)")
        }
    }
    
    private func updateUI(for message: BotMessage) {
        switch message.answerType {
        case .non:
            print("message type - non")
            bottomView.isHidden = true
            selectionMessageCollection.isUserInteractionEnabled = false
            textField.isUserInteractionEnabled = false
            sentMessageButton.isUserInteractionEnabled = false
        case .text:
            print("message type - text")
            bottomView.isHidden = false
            textField.isHidden = false
            sentMessageButton.isHidden = false
            selectionMessageCollection.isHidden = true
            textField.keyboardType = .alphabet
            textField.reloadInputViews()
            textField.isUserInteractionEnabled = true
            sentMessageButton.isUserInteractionEnabled = true
        case .phone:
            print("message type - phone")
            bottomView.isHidden = false
            textField.isHidden = false
            sentMessageButton.isHidden = false
            selectionMessageCollection.isHidden = true
            textField.keyboardType = .numberPad
            textField.reloadInputViews()
            textField.isUserInteractionEnabled = true
            sentMessageButton.isUserInteractionEnabled = true
        case .select:
            print("message type - select")
            bottomView.isHidden = false
            textField.isHidden = true
            sentMessageButton.isHidden = true
            selectionMessageCollection.isHidden = false
            selectionMessageCollection.reloadData()
            selectionMessageCollection.isUserInteractionEnabled = true
            textField.resignFirstResponder()
        case .finished:
            print("message type - finished")
            bottomView.isHidden = true
            textField.resignFirstResponder()
        }
    }
       
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == selectionMessageCollection) {
            let answerText = (messages.last as? BotMessage)?.potentialAnswers?[indexPath.row] ?? "---"
            sendAnswer(answerText)
            
            selectionMessageCollection.isHidden = true
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cellNumber: Int
        if (collectionView == chatCollection) {
            cellNumber = messages.count
        }
        else { // selectionMessageCollection
            cellNumber = (messages.last as? BotMessage)?.potentialAnswers?.count ?? 0
        }
        return cellNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
        if (collectionView == chatCollection) {
            let message = messages[indexPath.row]
            
            switch message.self {
            case is BotMessage:
                let message = message as! BotMessage
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BotCell", for: indexPath) as! BotCell
                if ((indexPath.row == self.messages.count - 1)  &&  !self.animatedMessages.contains(indexPath)) {
                    self.animatedMessages.append(indexPath)
                    (cell as! BotCell).message.animate(newText: message.text, characterDelay: 0.1)
                }
                else {
                    (cell as! BotCell).message.text = message.text
                }
            default:
                let message = message as! UserMessage
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
                (cell as! UserCell).answer.text = message.text
            }
        }
        else {  // selectionMessageCollection
            let potentialAnswers = (messages.last as? BotMessage)?.potentialAnswers
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectionMessageCell", for: indexPath) as! SelectionMessageCell
            (cell as! SelectionMessageCell).label.text = potentialAnswers?[indexPath.row] ?? "---"
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    var padding: CGFloat { return 5 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = (collectionView == chatCollection) ? 1 : 2
        let paddingSpace = padding * CGFloat(itemsPerRow + 1)
        let availableWidth = collectionView.frame.size.width - CGFloat(paddingSpace)
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        var heightPerItem = CGFloat(50)
        
        if (collectionView == chatCollection) {
            let message = messages[indexPath.row]
            let text: String
            let cellWidth: CGFloat
            let cellHightPadding: CGFloat
            guard let font = UIFont(name: "Helvetica", size: 17.0) else { fatalError("error during creating Helvetica font") }
            
            switch message.self {
            case is BotMessage:
                text = (message as! BotMessage).text
                cellWidth = collectionView.bounds.size.width - BotCell.leftChatCellConstraintValue - BotCell.rightChatCellConstraintValue
                cellHightPadding = text.height(withConstrainedWidth: cellWidth, font: font) + BotCell.topChatCellConstraintValue
            default:
                text = (message as! UserMessage).text
                cellWidth = collectionView.bounds.size.width - UserCell.leftChatCellConstraintValue - UserCell.rightChatCellConstraintValue
                cellHightPadding = text.height(withConstrainedWidth: cellWidth, font: font) + UserCell.topChatCellConstraintValue
                
            }
            heightPerItem = text.height(withConstrainedWidth: cellWidth, font: font) + cellHightPadding
        }
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if (collectionView == chatCollection) {
            return UIEdgeInsets(top: 2*padding, left: padding, bottom: 2*padding, right: padding)
        }
        else {
            return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.zero
    }
    
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let lastMessage = messages.last as? BotMessage else { return true }
        
        var res = false
        switch lastMessage.answerType {
        case .phone:
            if (string.unicodeScalars.count == 0) ||
                CharacterSet.decimalDigits.contains(string.unicodeScalars.first!) {
                res = true
            }
            else {
                // change sound or make vibration
            }
        case .text:
            if (string.unicodeScalars.count == 0) ||
                CharacterSet.lowercaseLetters.contains(string.unicodeScalars.first!) {
                res = true
            }
            else {
                // change sound or make vibration
            }
        default:
            break
        }
        return res
    }
    
}

// MARK: - Keyboard
extension ViewController {
    
  @objc func keyboardWillShow(_ notification: Notification) {
    adjustInsetForKeyboardShow(true, notification: notification)
  }
  
  @objc func keyboardWillHide(_ notification: Notification) {
    adjustInsetForKeyboardShow(false, notification: notification)
  }
  
  func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
    guard
      let userInfo = notification.userInfo,
      let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
      else {
        return
    }
    
    let adjustmentHeight = (show ? keyboardFrame.cgRectValue.height - 34 : 0)   // TODO: update this 34 value with safeArea
    UIView.animate(withDuration: 0.3, animations: {
        self.bottomConstraint.constant = adjustmentHeight
        self.view.layoutIfNeeded()
    }) { _ in
        let lastItemIndexPath = IndexPath(row: (self.messages.count - 1), section: 0)
            self.chatCollection.scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
    }
  }
}
