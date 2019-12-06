//
//  UserService.swift
//  Firestore-iOS
//
//  Created by Eno Reyes on 12/5/19.
//  Copyright © 2019 Eno Reyes. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserService {
    
    static func getCurrentUser(completion: @escaping (User) -> Void){
        
        let db = Firestore.firestore()
        let userUID = UserDefaults.standard.object(forKey: "uid")
                
        let userInfo = db.collection("users").document(userUID as? String ?? Auth.auth().currentUser!.uid)
        
        print(userInfo.path)
        
        userInfo.getDocument { (document, error) in
            if let document = document, document.exists {
                let currUser = User(dictionary: document.data()!, id: document.documentID)
                completion(currUser!)
            } else {
                print("Error: \(error)")
            }
        }
    }
    
    static func getUser(id: String, completion: @escaping (User) -> Void){
        
        let db = Firestore.firestore()
        let userInfo = db.collection("users").document(id)
                
        userInfo.getDocument { (document, error) in
            
            if let document = document, document.exists {
                
                let currUser = User(dictionary: document.data()!, id: document.documentID)
                completion(currUser!)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    static func swipedRightOnUser(swiperId: String, swipedId: String) {
        
        let db = Firestore.firestore()
        let userInfo = db.collection("users").document(swiperId).collection("swipedRight").document(swipedId)
        
        userInfo.setData(["id":swipedId]) { (error) in
            print("error swiping: \(error)")
        }
        
    }
    
    static func swipedLeftOnUser(swiperId: String, swipedId: String) {
        
        let db = Firestore.firestore()
        let userInfo = db.collection("users").document(swiperId).collection("swipedLeft").document(swipedId)
        
        userInfo.setData(["id":swipedId]) { (error) in
            if error != nil {
                print("error swiping: \(error)")
            }
        }
        
    }
    
    static func checkForMatch(swiperId: String, swipedId: String, completion: @escaping (Bool) -> Void) {
        
        let db = Firestore.firestore()
        let userInfoRef = db.collection("users").document(swipedId).collection("swipedRight")
        var didMatch = false
        
        userInfoRef.whereField("id", isEqualTo: swiperId)
            .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            didMatch = true
                            print("\(document.documentID) => \(document.data())")
                            completion(didMatch)
                        }
                    }
            }
        
        completion(didMatch)
        }
    
    static func createChannel(uid: String, ouid: String, completion: @escaping (Bool) -> Void) {
        
        let db = Firestore.firestore()

        UserService.getUser(id: uid) { (currentUser) in
                
            let channelReference = db.collection("users").document(currentUser.id!).collection("channels")
        
            UserService.getUser(id: ouid) { (userModel) in
                    
                    let channel = Channel(user: currentUser, otherUser: userModel)
                    
                    channelReference.document(ouid).setData(channel.representation) { error in
                      if let e = error {
                        print("Error saving channel: \(e.localizedDescription)")
                        completion(false)
                      }
                    }
                    
                    let otherReference = db.collection("users").document(ouid).collection("channels").document(currentUser.id!)
                                
                    let otherChannel = Channel(user: userModel, otherUser: currentUser)
                    
                    otherReference.setData(otherChannel.representation) { error in
                      if let e = error {
                        print("Error saving channel: \(e.localizedDescription)")
                      }
                    }
                    
                }
        }
        
        completion(true)
        
    }
    
}
