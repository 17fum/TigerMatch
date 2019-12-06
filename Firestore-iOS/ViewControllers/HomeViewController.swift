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
    public var currentUser: User?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add user's first name to the title
        UserService.getCurrentUser { (user) in
            self.titleLabel.text! = "Welcome, \(user.firstName!)!"
            self.currentUser = user
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
                                                
                if let user = User(dictionary: document.data(), id: document.documentID) {
                    
                    return user
                    
                } else {
                    //fatalError("Unable to initialize type \(User.self) with dictionary \(document.data())")
                    return User(id: "", email: "", profileImageUrl: "", firstName: "", lastName: "", description: "")
                }
            }
             
            self.users = results
            
            let userUID = UserDefaults.standard.object(forKey: "uid") as! String
            // Removing the user instance
            self.users.removeAll{$0.id == userUID}
            
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }

    @IBAction func transitionToMessages(_ sender: Any) {
                
        if (currentUser) != nil {
                        
            let nvc = storyboard?.instantiateViewController(withIdentifier: "mainNC") as! UINavigationController
            let vc  = storyboard?.instantiateViewController(withIdentifier: "channelsVC") as! ChannelsViewController
            vc.currentUser = currentUser
            nvc.pushViewController(vc, animated: true)
            view.window?.rootViewController = nvc
            view.window?.makeKeyAndVisible()
            
        }
    }
    
    func checkForMatch(swiperId: String, swipedId: String) {
        
        UserService.checkForMatch(swiperId: swiperId, swipedId: swipedId) { (didMatch) in
            
            print("didMatch")
            print(didMatch)
            
            if (didMatch) {
                print("SUCCESS - MATCH MADE!")
                print("and it was here")
                UserService.createChannel(uid: swiperId, ouid: swipedId) { (channelWasCreated) in
                    print("Channel was created: \(channelWasCreated)")
                }
            }
            
        }
        
    }
    
}

extension HomeViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
        titleLabel.text = "No More Users Left!"
    }

    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        
        profileVC.user = users[index]

        profileVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        profileVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve

        self.present(profileVC, animated: true, completion: nil)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        switch direction {
        case .left:
          print("swipedLeft")
            UserService.swipedLeftOnUser(swiperId: (currentUser?.id)!, swipedId: users[index].id!)
                        
        case .right:
            
            print("swipedRight")
            print(users[index].id!)
            print(currentUser)
            
            UserService.swipedRightOnUser(swiperId: (currentUser?.id)!, swipedId: users[index].id!)
            
            checkForMatch(swiperId: (currentUser?.id)!, swipedId: users[index].id!)
        default:
          break
        }
        
    }
}

extension HomeViewController: KolodaViewDataSource {

    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return users.count
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = UIImageView(image: UIImage(named: "defaultImage"))
        view.layer.masksToBounds = true
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.cornerRadius = 20
        
        let fullName = UILabel(frame: CGRect(x: 0, y: 260, width: 300, height: 30))
        fullName.textColor = UIColor.black
        fullName.backgroundColor = UIColor.white
        fullName.text = "   " + users[index].firstName! + " " + users[index].lastName!
        fullName.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        view.addSubview(fullName)
      
        guard let imageUrl = users[index].profileImageUrl else {
            return view
        }
        
        view.downloaded(from: imageUrl)
        view.contentMode = .scaleAspectFill
        return view
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? OverlayView
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
