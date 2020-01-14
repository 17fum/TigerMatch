//
//  OnboardingViewController.swift
//  Firestore-iOS
//
//  Created by Max Fu on 11/19/19.
//  Copyright © 2019 Max Fu. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class OnboardingViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var classText: UITextField!
    @IBOutlet weak var bioText: UITextField!
    @IBOutlet weak var swipeButton: UIButton!
    @IBOutlet weak var userPhoto: UIImageView!
    
    var defaultImage = "defaultImage"
    var storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        view.addGestureRecognizer(tap)
        
        userPhoto.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: "didTapImage")
        userPhoto.addGestureRecognizer(imageTap)
        
        swipeButton.layer.cornerRadius = 10
        userPhoto.image = UIImage(named: defaultImage)
        hideErrorLabel()
        
        registerForKeyboardNotifications()

        // Do any additional setup after loading the view.
    }
    
    @objc private func didTapImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        //picker.allowsEditing = true
        present(picker, animated:true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func registerForKeyboardNotifications() {
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
     }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func startSwipingTapped(_  sender: Any){
        if let text = bioText.text, !text.isEmpty && ((classText?.text) != nil), !text.isEmpty {
            let db = Firestore.firestore()
            let uid = Auth.auth().currentUser!.uid
            db.collection("users").document(uid).updateData(["description": bioText.text as Any, "classYear": classText.text as Any], completion: { (error) in
                // something went wrong when saving first and last name
                if error != nil {
                    self.showError("User data couldn't be saved properly")
                }
            })
            self.transitionToHome()
        }
        else{
            self.showError("please fill in above fields!")
        }
        
    }

}

extension OnboardingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // random string as placeholder for image filename
        let randomID = UUID.init().uuidString
        let originalImage = info[.originalImage] as? UIImage
        userPhoto.image = originalImage
        
        dismiss(animated: true, completion: nil)
        var data = NSData()
        data = userPhoto.image!.jpegData(compressionQuality: 0.8)! as NSData
        // set upload path
        let filePath = "images/\(randomID).jpg"
      
        //let filePath = "\(Auth.auth().currentUser!.uid)/\("userPhoto")"
        let metaData = StorageMetadata.init()
        metaData.contentType = "image/jpg"
        self.storageRef.child(filePath).putData(data as Data, metadata: metaData){(downloadmetaData,error) in
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }else{
            //store downloadURL in database
                let uploadRef = Storage.storage().reference(withPath: filePath)
                uploadRef.downloadURL{ url, error in
                    if let error = error {
                        self.showError("\(error.localizedDescription)")
                    }
                    // updating profileImageURL for user
                    if let url = url{
                        let db = Firestore.firestore()
                        let uid = Auth.auth().currentUser!.uid
                        db.collection("users").document(uid).updateData(["profileImageUrl": url.absoluteString], completion: { (error) in
                            // something went wrong when saving first and last name
                            if error != nil {
                                self.showError("User data couldn't be saved properly")
                            }
                        })
                    }
                }
            }
        }
    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print("cancelled")
//    }
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    func hideErrorLabel() {
        errorLabel.alpha = 0
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
}
    
