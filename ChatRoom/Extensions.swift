//
//  Extensions.swift
//  ChatRoom
//
//  Created by Max Livingston on 8/18/17.
//  Copyright © 2017 Max Livingston. All rights reserved.
//

import UIKit
import Firebase

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
    
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = cachedImage as? UIImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
            
        }).resume()
        
    }
}

extension MessagesController {
    
    func handleSelectProfileImageView() {
        let  picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        
        updateImage()
        
        dismiss(animated: true, completion: nil)
    }
    
    func updateImage() {
        let imageName = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child("profile_Images").child(imageName)
        
        let uploadImage = UIImageJPEGRepresentation(profileImageView.image!, 0.1)
        
        storageRef.putData(uploadImage!, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            if let profileImageURL = metadata?.downloadURL()?.absoluteString{
                let values = ["profileImageURL": profileImageURL ]
                let uid = Auth.auth().currentUser?.uid
                let reference = Database.database().reference()
                let usersReference = reference.child("users").child(uid!)
                
                usersReference.updateChildValues(values)
                
            }
        })
    }

}
