//
//  DatabaseRepresentation.swift
//  Firestore-iOS
//
//  Created by Eno Reyes on 2019-11-18.
//  Copyright © 2019 Eno Reyes. All rights reserved.
//

import Foundation

protocol DatabaseRepresentation {
  var representation: [String: Any] { get }
}
