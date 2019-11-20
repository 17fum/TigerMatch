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

    @IBOutlet weak var userPhoto: UIImageView!
    
    var storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        
        
   

        // Do any additional setup after loading the view.
    }
    
//    func uploadImagePic(img1 :UIImage){
//        var data = NSData()
//        data = img1.jpegData(compressionQuality: 0.8)! as NSData
//        // set upload path
//        let filePath = "images/1324.jpg" // path where you wanted to store img in storage
//        let metaData = StorageMetadata()
//        metaData.contentType = "image/jpg"
//
//        self.storageRef = Storage.storage().reference()
//        self.storageRef.child(filePath).putData(data as Data, metadata: metaData){(metaData,error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }else{
//                //store downloadURL
//                let downloadURL = metaData?.path
//
//            }
//        }
//    }
    
    @IBAction func uploadImageTapped(_  sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        //picker.allowsEditing = true
        present(picker, animated:true, completion: nil)

    
    }


}

extension OnboardingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let originalImage = info[.originalImage] as? UIImage
        userPhoto.image = originalImage
        
        dismiss(animated: true, completion: nil)
        var data = NSData()
        data = userPhoto.image!.jpegData(compressionQuality: 0.8)! as NSData
        // set upload path
        let filePath = "images/hello.jpg"
      
        //let filePath = "\(Auth.auth().currentUser!.uid)/\("userPhoto")"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        self.storageRef.child(filePath).putData(data as Data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
            //store downloadURL
                //let downloadURL = (metaData!.downloadURL() as AnyObject).absoluteString
            //store downloadURL at database
               print("yay") //self.databaseRef.child("users").child(Auth.auth()!.currentUser!.uid).updateChildValues(["userPhoto": downloadURL])
            }

            }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
    }
    
}
    
