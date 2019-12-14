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
        
        userImage.downloaded(from: user!.profileImageUrl!)
        otherUserImage.downloaded(from: otherUser!.profileImageUrl!)
        userImage.makeRounded()
        otherUserImage.makeRounded()
        
    }

    @IBAction func sendMessageTouchUpInside(_ sender: Any) {

        let nvc = storyboard?.instantiateViewController(withIdentifier: "mainNC") as! UINavigationController
        let vc  = ChatViewController(user: user!, otherUser: otherUser!, channel: channel!)
        nvc.pushViewController(vc, animated: true)
        view.window?.rootViewController = nvc
        view.window?.makeKeyAndVisible()
        
    }
    
    
    @IBAction func keepSwipingTouchUpInside(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
}
