//
//  Channel.swift
//  Firestore-iOS
//
//  Created by Eno Reyes on 2019-11-18.
//  Copyright © 2019 Eno Reyes. All rights reserved.
//

import FirebaseFirestore

struct Channel {
  
    let id: String?
    let name: String
    var user: String?
    var otherUser: String?
    
    //TODO: Need to add reference to the other user in the chat. 
  
    init(user: User, otherUser: User) {
        
        let firstName = (otherUser.firstName)!
        id = otherUser.id
        self.name = firstName
        self.user = user.id
        self.otherUser = otherUser.id

    }
  
  init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    
    guard let name = data["name"] as? String else {
      return nil
    }
    
    guard let uid = data["user"] as? String else {
        
        print("problems here 1")
        
      return nil
    }
    
    guard let ouid = data["otherUser"] as? String else {
        
        print("problems here 2")
        
      return nil
    }
    
    self.user = uid
    self.otherUser = ouid
    
    id = document.documentID
    self.name = name
  }
  
}

extension Channel: DatabaseRepresentation {
  
  var representation: [String : Any] {
    
    var rep: [String : Any] = [
      "name": name,
      "user": user,
      "otherUser": otherUser
    ]
    
    return rep
  }
  
}

extension Channel: Comparable {
  
  static func == (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.name < rhs.name
  }

}
