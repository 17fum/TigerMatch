//
//  ViewController.swift
//  Firestore-iOS
//
//  Created by Eno Reyes on 2019-11-18.
//  Copyright © 2019 Eno Reyes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 15;
        signUpButton.layer.cornerRadius = 15;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Check if the user is already logged in
        if UserDefaults.standard.object(forKey: "uid") != nil {
            transitionToHome()
        }
    }

    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}

