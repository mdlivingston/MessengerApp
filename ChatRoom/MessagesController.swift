//
//  ViewController.swift
//  ChatRoom
//
//  Created by Max Livingston on 8/17/17.
//  Copyright © 2017 Max Livingston. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    
    lazy var profileImageView: UIImageView = {
        let profileImage = UIImageView()
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImage.isUserInteractionEnabled = true
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 17.5
        profileImage.contentMode = .scaleAspectFill
        profileImage.backgroundColor = UIColor.clear
        return profileImage
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "loadName"), object: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(handleNewMessage))
        
        tableView?.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "cellId")
        
        checkIfUserIsLoggedIn()
        obeserveUserMessages()
    }
    
    
    func obeserveUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let reference = Database.database().reference().child("user-messages").child(uid)
        reference.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    let message = Message()
                    message.setValuesForKeys(dictionary)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messageDictionary[chatPartnerId] = message
                        self.messages = Array(self.messageDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
                        })
                    }
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                }
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    var timer: Timer?
    
    func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        
        let chatPartnerId = message.chatPartnerId()
        
        //Declaration
        if let id = chatPartnerId {
            let reference = Database.database().reference().child("users").child(id)
            reference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: Any] {
                    cell.friendLabel.text = dictionary["name"] as? String
                    
                    cell.profileImage.image = UIImage(named: "loginImage")
                    if dictionary["profileImageURL"] != nil {
                        cell.profileImage.loadImageUsingCacheWithUrlString(urlString: dictionary["profileImageURL"] as! String)
                    }
                }
            })
            
            cell.messageLabel.text = message.text
            
            if message.timeStamp != nil {
                
                if let seconds = message.timeStamp?.doubleValue {
                    let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a"
                    cell.timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {
                return
            }
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
    }
    
    func loadList() {
        checkIfUserIsLoggedIn()
    }
    
    func setupNavBarWithUser(user: User) {
        self.navigationItem.title = user.name
        
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
        titleView.backgroundColor = UIColor.clear
        
        let nameTextView = UITextView()
        nameTextView.translatesAutoresizingMaskIntoConstraints = false
        nameTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        nameTextView.text = user.name
        nameTextView.backgroundColor = UIColor.clear
        nameTextView.textAlignment = .left
        nameTextView.font = nameTextView.font?.withSize(13)
        nameTextView.isEditable = false
        
        
        if let profileImageUrl = user.profileImageURL {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        titleView.addSubview(profileImageView)
        titleView.addSubview(nameTextView)
        
        
        profileImageView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor, constant: -45).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        profileImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        nameTextView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor).isActive = true
        nameTextView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor, constant: -2).isActive = true
        
        nameTextView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        nameTextView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    func showChatControllerForUser(user: User) {
        let chatMessages = ChatMessagesController(collectionViewLayout: UICollectionViewFlowLayout())
        chatMessages.user = user
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(chatMessages, animated: true)
        
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
        } else {
            let uid = Auth.auth().currentUser?.uid
            let reference = Database.database().reference(fromURL: "https://chatroom-462bf.firebaseio.com/")
            reference.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let user = User()
                    user.setValuesForKeys(dictionary)
                    self.setupNavBarWithUser(user: user)
                    self.obeserveUserMessages()
                }
            }, withCancel: nil)
        }
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messages = self
        //banner at the top of message page
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        }
        catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}

