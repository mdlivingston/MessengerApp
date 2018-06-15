

import UIKit
import Firebase

class ChatMessagesController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let reference = Database.database().reference().child("user-messages").child(uid)
        
        reference.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else {
                    return
                }
                let message = Message()
                
                //if keys dont match it will crash
                message.setValuesForKeys(dictionary)
                
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        
                    }
                }
            }, withCancel: nil)
            
            
        }, withCancel: nil)
        
        
    }
    let cellId = "cellId"
    
    lazy var textField: UITextField = {
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.placeholder = "Enter Message..."
        text.delegate = self
        
        return text
    }()
    
    let messageBar: UIView = {
        let message = UIView()
        message.backgroundColor = UIColor.white
        message.translatesAutoresizingMaskIntoConstraints = false
        return message
    }()
    
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //8 pixels of padding on top
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        
        //scrollToBottom()
        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let messageBarBorder = UIView()
        messageBarBorder.translatesAutoresizingMaskIntoConstraints = false
        messageBarBorder.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        containerView.addSubview(messageBarBorder)
        messageBarBorder.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        messageBarBorder.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        messageBarBorder.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        messageBarBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let sendButton = UIButton(type: UIButtonType.system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        containerView.addSubview(self.textField)
        self.textField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        self.textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.textField.widthAnchor.constraint(equalToConstant: containerView.frame.size.width - 50).isActive = true
        self.textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return containerView
        
    }()
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    func setupKeyboardObservers() {
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        if let profileImageUrl = self.user?.profileImageURL {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //incoming blue
            cell.bubbleView.backgroundColor = ChatMessageCell.coolBlue
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    func handleKeyboardNotification(notification: NSNotification) {
        
        let isKeyboardShowing = notification.name == .UIKeyboardWillShow
        
        if isKeyboardShowing {
            //scrollToBottom()
        }
    }
    
    private func scrollToBottom() {
        let lastSectionIndex = (collectionView?.numberOfSections)! - 1
        let lastItemIndex = (collectionView?.numberOfItems(inSection: lastSectionIndex))! - 1
        let indexPath = IndexPath(item: lastItemIndex, section: lastSectionIndex)
        collectionView!.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    func setupMessageBarComponents() {
        
        view.addSubview(messageBar)
        messageBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        messageBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        messageBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        messageBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let messageBarBorder = UIView()
        messageBarBorder.translatesAutoresizingMaskIntoConstraints = false
        messageBarBorder.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        messageBar.addSubview(messageBarBorder)
        messageBarBorder.leftAnchor.constraint(equalTo: messageBar.leftAnchor).isActive = true
        messageBarBorder.topAnchor.constraint(equalTo: messageBar.topAnchor).isActive = true
        messageBarBorder.widthAnchor.constraint(equalTo: messageBar.widthAnchor).isActive = true
        messageBarBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        let sendButton = UIButton(type: UIButtonType.system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        messageBar.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: messageBar.rightAnchor, constant: -10).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: messageBar.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        messageBar.addSubview(textField)
        textField.leftAnchor.constraint(equalTo: messageBar.leftAnchor, constant: 10).isActive = true
        textField.centerYAnchor.constraint(equalTo: messageBar.centerYAnchor).isActive = true
        textField.widthAnchor.constraint(equalToConstant: view.frame.size.width - 50).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    
    func handleSend() {
        
        let reference = Database.database().reference().child("messages")
        //creates unique key for message
        let childReference = reference.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = NSDate().timeIntervalSince1970
        let values = ["text": textField.text!, "toId": toId, "fromId": fromId, "timeStamp": timeStamp] as [String: Any]
        childReference.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId)
            let messageId = childReference.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            
        }
        
        //clears text field after send
        textField.text = ""
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
