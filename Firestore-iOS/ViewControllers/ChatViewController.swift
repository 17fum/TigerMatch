//
//  ViewController.swift
//  Firestore-iOS
//
//  Created by Eno Reyes on 2019-11-18.
//  Copyright © 2019 Eno Reyes. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import FirebaseFirestore

final class ChatViewController: MessagesViewController {
   
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    private let user: User
    private let channel: Channel
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
  
    init(user: User, channel: Channel) {
        self.user = user
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
        title = channel.name
    }
    
    deinit {
      messageListener?.remove()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
      override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let id = channel.id else {
          navigationController?.popViewController(animated: true)
          return
        }

        let userChannels = db.collection("users").document((user.id!))
        
        reference = userChannels.collection(["channels", id, "thread"].joined(separator: "/"))
        
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
          guard let snapshot = querySnapshot else {
            print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
            return
          }
                      
          snapshot.documentChanges.forEach { change in
                        
            self.handleDocumentChange(change)
          }
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = Constants.primary
        messageInputBar.inputTextView.textColor = .black
        messageInputBar.sendButton.setTitleColor(Constants.primary, for: .normal)
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
      }
    
    private func insertNewMessage(_ message: Message) {
      guard !messages.contains(message) else {
        return
      }
        
      messages.append(message)
      messages.sort()
      
      let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
      let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
              
      messagesCollectionView.reloadData()
              
      if shouldScrollToBottom {
        DispatchQueue.main.async {
          self.messagesCollectionView.scrollToBottom(animated: true)
        }
      }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        
        guard let message = Message(document: change.document) else {            
            return
      }
        
        print(message)

      switch change.type {
      case .added:
        insertNewMessage(message)

      default:
        break
      }
    }
    
    private func save(_ message: Message) {
        
        UserService.getUser(id: channel.otherUser!) { (otherUser) in
            print(otherUser)
            
            let userChannels = self.db.collection("users").document((otherUser.id)!)
              
            let reference = userChannels.collection(["channels", self.user.id!, "thread"].joined(separator: "/"))
              
            reference.addDocument(data: message.representation) { error in
              if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
              }
            }
            
            let otherUserChannels = self.db.collection("users").document(self.user.id!)
                     
            let otherReference = otherUserChannels.collection(["channels", otherUser.id!, "thread"].joined(separator: "/"))
                     
                   otherReference.addDocument(data: message.representation) { error in
                     if let e = error {
                       print("Error sending message: \(e.localizedDescription)")
                       return
                }
            }
        }
        
       
        
        /*
        
        let userChannels = db.collection("users").document((otherUser?.id)!)
        
        reference = userChannels.collection(["channels", user.id!, "thread"].joined(separator: "/"))
        
      reference?.addDocument(data: message.representation) { error in
        if let e = error {
          print("Error sending message: \(e.localizedDescription)")
          return
        }
        
        self.messagesCollectionView.scrollToBottom()
 
         
      }
         */
    }
  
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> UIColor {
    
    // 1
    return isFromCurrentSender(message: message) ? Constants.primary : Constants.incomingMessage
  }

  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> Bool {

    // 2
    return false
  }

  func messageStyle(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft

    // 3
    return .bubbleTail(corner, .curved)
  }
}

extension ChatViewController: MessagesLayoutDelegate {

  func avatarSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

    // 1
    return .zero
  }

  func footerViewSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

    // 2
    return CGSize(width: 0, height: 8)
  }

  func heightForLocation(message: MessageType, at indexPath: IndexPath,
    with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

    // 3
    return 0
  }
}

extension ChatViewController: MessagesDataSource {
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    

  // 1
  func currentSender() -> SenderType {
        let fullName = user.firstName! + " " + user.lastName!
        return Sender(id: user.id!, displayName: fullName)
  }

  // 2
  func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }

  // 3
  func messageForItem(at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> MessageType {
            
    return messages[indexPath.section]
  }

  // 4
  func cellTopLabelAttributedText(for message: MessageType,
    at indexPath: IndexPath) -> NSAttributedString? {

        let name = message.sender.displayName
        return NSAttributedString(
          string: name,
          attributes: [
            .font: UIFont.preferredFont(forTextStyle: .caption1),
            .foregroundColor: UIColor(white: 0.3, alpha: 1)
          ]
    )
  }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
  
    func inputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {

      // 1
      let message = Message(user: user, content: text)

      // 2
      save(message)
        
        print("test")

      // 3
      inputBar.inputTextView.text = ""
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
}

extension UIScrollView {
  
  var isAtBottom: Bool {
    return contentOffset.y >= verticalOffsetForBottom
  }
  
  var verticalOffsetForBottom: CGFloat {
    let scrollViewHeight = bounds.height
    let scrollContentSizeHeight = contentSize.height
    let bottomInset = contentInset.bottom
    let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
    return scrollViewBottomOffset
  }
  
}
