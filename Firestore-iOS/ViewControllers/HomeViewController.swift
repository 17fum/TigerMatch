//
//  HomeViewController.swift
//  Firestore-iOS
//
//  Created by Eno Reyes on 2019-11-18.
//  Copyright © 2019 Eno Reyes. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import Koloda

class HomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var kolodaView: KolodaView!
    
    var images = ["cat-1", "cat-2", "cat-3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add user's first name to the title
        getUserName { (name) in
            self.titleLabel.text! = "Welcome, \(name)!"
        }
        
        // Initiate the kolodaView
        kolodaView.dataSource = self
        kolodaView.delegate = self

    }
    
    // get the signed-in user's first name using their uid from Cloud Firestore
    func getUserName(completion: @escaping (String) -> Void){
        
        let db = Firestore.firestore()
        let userUID = UserDefaults.standard.object(forKey: "uid")
        
        let userName = UserDefaults.standard.object(forKey: "userFirstName")
        
        let userInfo = db.collection("users").document(userUID as? String ?? Auth.auth().currentUser!.uid)
        
        // return user name from UserDefaults if it exists, otherwise get it from the database
        if userName != nil {
            completion(userName as! String)
        }
        else {
            userInfo.getDocument{ (document, error) in
                if let document = document, document.exists {
                    let data = document.data() ?? nil
                    UserDefaults.standard.set(data?["firstName"] as! String, forKey: "userFirstName")
                    UserDefaults.standard.synchronize()
                    completion(data?["firstName"] as! String)
                }
                else {
                    print(error?.localizedDescription ?? "nil")
                }
            }
        }

    }
    
    // MARK: IBActions
    @IBAction func noButtonTapped() {
        kolodaView?.swipe(.left)
    }

    @IBAction func yesButtonTapped() {
        kolodaView?.swipe(.right)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            if Auth.auth().currentUser == nil {
                // remove user session from device (and their first name)
                UserDefaults.standard.removeObject(forKey: "uid")
                UserDefaults.standard.removeObject(forKey: "userFirstName")
                UserDefaults.standard.synchronize()
                
                self.transitionToMain()
            }
        } catch _ as NSError {
            // handle logout error by showing an alert
            let alert = UIAlertController(title: "Logout Error", message: "There was an error logging you out. Try restarting the app, please.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func transitionToMain() {
        let initialViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.initialViewController) as? UINavigationController
        
        view.window?.rootViewController = initialViewController
        view.window?.makeKeyAndVisible()
    }
    
    

}

extension HomeViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
        print("Ran out of cards")
    }

    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        print("Hello")
    }
}

extension HomeViewController: KolodaViewDataSource {

    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return images.count
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = UIImageView(image: UIImage(named: images[index]))
        view.layer.masksToBounds = true
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.cornerRadius = 20
        return view
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}
