//
//  FormUtilities.swift
//  Firestore-iOS
//
//  Created by Eno Reyes on 2019-11-18.
//  Copyright © 2019 Eno Reyes. All rights reserved.
//

import Foundation
import UIKit

class FormUtilities {
    
    // test password validity against a regex pattern
    static func isValidPassword(_ password: String) -> Bool {
        // Minimum eight characters, at least one letter and one number
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$");
        return passwordTest.evaluate(with: password)
    }
    
    static func sanitizeInput(_ input:UITextField) -> String {
        return input.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+(@princeton.edu)"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
                        
            if results.count == 0
            {
                if Constants.debug == false {
                    returnValue = false
                }
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return returnValue
    }

}
