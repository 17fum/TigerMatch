//
//  User.swift
//  Firestore-iOS
//
//  Created by Eno Reyes on 2019-11-18.
//  Copyright © 2019 Eno Reyes. All rights reserved.
//

import Foundation

struct User{
    var id: String?
    var email: String?
    var profileImageUrl: String?
    var firstName: String?
    var lastName: String?
    var description: String?
    var classYear: String?
}
 
extension User{
    init?(dictionary: [String : Any], id: String) {
        guard let email = dictionary["email"] as? String,
            let profileImageUrl = dictionary["profileImageUrl"] as? String,
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let description = dictionary["description"] as? String,
            let classYear = dictionary["classYear"] as? String
            
            else { return nil }
         
        self.init(id: id, email: email, profileImageUrl: profileImageUrl, firstName: firstName, lastName: lastName, description: description, classYear: classYear)
    }
}
