//
//  ProfileViewController.swift
//  Firestore-iOS
//
//  Created by Daniel Huynh on 12/5/19.
//  Copyright © 2019 Daniel Huynh. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    public var user: User?
    public var bio = UITextView()
    
    
    override func viewDidLoad() {
        view.backgroundColor = .clear

        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        bio.frame = CGRect(x: 0, y: self.view.frame.height / 8,
                           width: self.view.frame.width, height: self.view.frame.height * (7/8))
        var bioText = (user?.firstName)! + " " + (user?.lastName)! + "\n\n" + (user?.classYear)!
        bioText += "\n\n\n"
        bioText += (user?.description)!
        bio.text = bioText
        bio.isEditable = false
        bio.font = .systemFont(ofSize: 36)
        self.view.addSubview(bio)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.bio.isHidden = true
//        view.removeFromSuperview()
        super.dismiss(animated: true)
    }
}
