//
//  HomeViewController.swift
//  Firestore-iOS
//
//  Created by Eno Reyes on 2019-11-18.
//  Copyright © 2019 Eno Reyes. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
import Koloda

class HomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var kolodaView: KolodaView!
    private var listener : ListenerRegistration!
    
    private var documents: [DocumentSnapshot] = []
    public var users: [User] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add user's first name to the title
        getUserName { (name) in
            self.titleLabel.text! = "Welcome, \(name)!"
        }
        
        // Initiate the kolodaView
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        // Begin query for users
        self.query = baseQuery()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Logic for querying users.
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
             
            let results = snapshot.documents.map { (document) -> User in
                
                print(document.data())
                
                if let user = User(dictionary: document.data(), id: document.documentID) {
                    return user
                } else {
                    fatalError("Unable to initialize type \(User.self) with dictionary \(document.data())")
                    //return User(id: "", email: "", profileImageUrl: "", firstName: "", lastName: "", description: "")
                }
            }
             
            self.users = results
            self.documents = snapshot.documents
            self.kolodaView.reloadData()
            
        }
    }
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("users").limit(to: 50)
    }
     
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
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
        return users.count
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let image = UIImageView()
        guard let imageUrl = users[index].profileImageUrl else {
            return UIImageView(image: UIImage(named: "defaultImage"))
        }
        
        image.downloaded(from: imageUrl)
        return image
        
    }
}

// Logic for background updating of images in the KoladaView
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
