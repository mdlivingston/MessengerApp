//
//  LoginController + Handlers.swift
//  ChatRoom
//
//  Created by Max Livingston on 8/18/17.
//  Copyright © 2017 Max Livingston. All rights reserved.
//

import UIKit
import Firebase


extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            loginImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else{
                print("Form is not valid")
                return
        }
        
        //Authenicate User
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            //successfully authenicated user
            guard let uid = user?.uid else {
                return
            }
            
            let imageName = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_Images").child(imageName)
            
            if let profileImage = self.loginImageView.image, let uploadImage = UIImageJPEGRepresentation(profileImage, 0.1){
                
                storageRef.putData(uploadImage, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString{
                        let values = ["name": name, "email": email, "profileImageURL": profileImageURL ]
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                    }
                })
            }
        }
    }
    func handleLoginRegister() {
        
        if loginRegisterSegementedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }
        else{
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text
            else{
                print("Form is not valid")
                return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            //Reload Name
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadName"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any]) {
        let reference = Database.database().reference()
        let usersReference = reference.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err,ref) in
            if err != nil {
                print(err!)
                return
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadName"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            print("Saved User Successfully Into Firebase Database")
        })
        
    }
    
}
