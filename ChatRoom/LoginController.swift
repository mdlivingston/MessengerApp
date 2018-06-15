//
//  LoginController.swift
//  ChatRoom
//
//  Created by Max Livingston on 8/17/17.
//  Copyright © 2017 Max Livingston. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    var messageController: MessagesController?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        //allows to resize
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let registerButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor(white: 0.75, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
        let nameField = UITextField()
        nameField.placeholder = "Name"
        nameField.translatesAutoresizingMaskIntoConstraints = false
        return nameField
    }()
    
    let nameLineSeparator: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    let emailTextField: UITextField = {
        let emailField = UITextField()
        emailField.placeholder = "Email Address"
        emailField.translatesAutoresizingMaskIntoConstraints = false
        return emailField
    }()
    
    let emailLineSeparator: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    let passwordTextField: UITextField = {
        let passwordField = UITextField()
        passwordField.placeholder = "Password"
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.isSecureTextEntry = true
        return passwordField
    }()
    
    lazy var loginImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "loginImage")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.addGestureRecognizer((UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView))))
        image.isUserInteractionEnabled = true
        image.layer.cornerRadius = 75
        image.layer.masksToBounds = true

        return image
    }()
    
    
    let loginRegisterSegementedControl: UISegmentedControl = {
        let segementedController = UISegmentedControl(items: ["Login", "Register"])
        segementedController.translatesAutoresizingMaskIntoConstraints = false
        segementedController.tintColor = UIColor.white
        segementedController.selectedSegmentIndex = 1
        segementedController.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return segementedController
    }()
    
    func handleLoginRegisterChange() {
        let text = loginRegisterSegementedControl.titleForSegment(at: loginRegisterSegementedControl.selectedSegmentIndex)
        registerButton.setTitle(text, for: .normal)
        
        //change hieght of input container view
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 100 : 150
        inputsContainerViewYAnchor?.constant = loginRegisterSegementedControl.selectedSegmentIndex == 0 ? -25 : 0
        
        //change height of name text field
        nameTextHeightAnchor?.isActive = false
        nameTextHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextField.placeholder = loginRegisterSegementedControl.selectedSegmentIndex == 0 ? "" : "Name"
        nameTextField.text =  ""
        nameTextHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = UIColor(white: 0.65, alpha: 1)
        
        view.addSubview(inputsContainerView)
        view.addSubview(registerButton)
        view.addSubview(loginImageView)
        view.addSubview(loginRegisterSegementedControl)
        
        //constraints for white box and such
        setupInputsContainerView()
        setupRegisterButton()
        setupLoginImage()
        setupSegementedControl()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func setupSegementedControl() {
        loginRegisterSegementedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegementedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        
        loginRegisterSegementedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegementedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
    }
    func setupLoginImage() {
        loginImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginImageView.bottomAnchor.constraint(equalTo: loginRegisterSegementedControl.topAnchor, constant: -40).isActive = true
        
        loginImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        loginImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupRegisterButton() {
        //x & y
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        //width and height
        registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var inputsContainerViewYAnchor: NSLayoutConstraint?
    var nameTextHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        
        //x & y white box
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerViewYAnchor = inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        inputsContainerViewYAnchor?.isActive = true
        
        //width & height white box
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameLineSeparator)
        
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        nameTextHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextHeightAnchor?.isActive = true
        
        nameLineSeparator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameLineSeparator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        
        nameLineSeparator.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameLineSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailLineSeparator)
        
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        emailLineSeparator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailLineSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        
        emailLineSeparator.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailLineSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        inputsContainerView.addSubview(passwordTextField)
        
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)    }
}
