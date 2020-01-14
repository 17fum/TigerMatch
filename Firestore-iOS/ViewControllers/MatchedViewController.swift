//
//  MatchedViewController.swift
//  
//
//  Created by Eno Reyes on 12/13/19.
//

import UIKit

class MatchedViewController: UIViewController {

    @IBOutlet weak var matchText: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var otherUserImage: UIImageView!
    
    public var user: User?
    public var otherUser: User?
    public var channel: Channel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isOpaque = false
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
        
        userImage.downloaded(from: user!.profileImageUrl!)
        otherUserImage.downloaded(from: otherUser!.profileImageUrl!)
        userImage.makeRounded()
        otherUserImage.makeRounded()
        
        let name = otherUser?.firstName
        
        matchText.text = "You and \(name!) have liked eachother!"
        
    }

    @IBAction func sendMessageTouchUpInside(_ sender: Any) {

        if (user != nil && channel != nil && otherUser != nil) {
                        
            let nvc = storyboard?.instantiateViewController(withIdentifier: "mainNC") as! UINavigationController
            let vc = ChatViewController(user: user!, otherUser: otherUser!, channel: channel!)
            nvc.pushViewController(vc, animated: true)
            view.window?.rootViewController = nvc
            view.window?.makeKeyAndVisible()
        }
        
    }
    
    
    @IBAction func keepSwipingTouchUpInside(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
}
