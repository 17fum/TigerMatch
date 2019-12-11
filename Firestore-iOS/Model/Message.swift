//
//  Message.swift
//  Firestore-iOS
//
//  Created by Eno Reyes on 12/5/19.
//  Copyright © 2019 Eno Reyes. All rights reserved.
//

import Firebase
import MessageKit
import FirebaseFirestore

struct Message: MessageType {
  
  let id: String?
  let content: String
  let sentDate: Date
  let sender: SenderType
  var kind: MessageKind
  
  var messageId: String {
    return id ?? UUID().uuidString
  }
  
  var image: UIImage? = nil
  var downloadURL: URL? = nil
  
    init(user: User, content: String) {
                
        let fullName = user.firstName! + " " + user.lastName!
        
        sender = Sender(id: user.id!, displayName: fullName)
        self.content = content
        sentDate = Date()
        id = nil
        kind = .text(content)
  }
  
  init(user: User, image: UIImage) {
    
    let fullName = user.firstName! + " " + user.lastName!
    
    sender = Sender(id: user.id!, displayName: fullName)
    self.image = image
    content = ""
    sentDate = Date()
    id = nil
    kind = .photo(ImageMediaItem(image: image))
  }
  
  init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    
    let firebaseDate = data["created"] as? Timestamp
        
    let sentDate = firebaseDate!.dateValue()
    
    guard let senderID = data["senderID"] as? String else {
        
        print("error here 2")
        
      return nil
    }
    guard let senderName = data["senderName"] as? String else {
        
        print("error here 3")
        
      return nil
    }
    
    id = document.documentID
    
    self.sentDate = sentDate
    sender = Sender(id: senderID, displayName: senderName)
    
    if let content = data["content"] as? String {
      self.content = content
      downloadURL = nil
      kind = .text(content)
    } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
      downloadURL = url
      content = ""
        
      // IF IT IS BREAKING ON LOADING IMAGES, ITS DEFINITELY THIS
      let image = UIImage()
        
      kind = .photo(ImageMediaItem(image: image))
    } else {
        
        print("error here 4")
        
      return nil
    }
  }
  
}

extension Message: DatabaseRepresentation {
  
  var representation: [String : Any] {
    var rep: [String : Any] = [
      "created": sentDate,
      "senderID": sender.senderId,
      "senderName": sender.displayName
    ]
    
    if let url = downloadURL {
      rep["url"] = url.absoluteString
    } else {
      rep["content"] = content
    }
    
    return rep
  }
  
}

extension Message: Comparable {
  
  static func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Message, rhs: Message) -> Bool {
    return lhs.sentDate < rhs.sentDate
  }
  
}

private struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

}
