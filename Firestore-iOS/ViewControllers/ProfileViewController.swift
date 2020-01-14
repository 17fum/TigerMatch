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
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var classLabel: UILabel!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        view.backgroundColor = .clear

        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        
        view.sendSubviewToBack(blurEffectView)

        let name = (user?.firstName)! + " " + (user?.lastName)!
        let classYear = (user?.classYear)!
        let description = (user?.description)!
        
        if let imageUrl = user?.profileImageUrl {
            profileImage.downloaded(from: imageUrl)
            profileImage.contentMode = .scaleAspectFill
        } else {
            profileImage.image = UIImage(named: "defaultImage")
        }
                
        nameLabel.text = name
        classLabel.text = "Class of \(classYear)"
        bioTextView.text = description
        bioTextView.isEditable = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.bio.isHidden = true
//        view.removeFromSuperview()
        super.dismiss(animated: true)
    }
}
