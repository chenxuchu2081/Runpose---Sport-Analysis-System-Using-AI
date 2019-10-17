//
//  SignupPage.swift
//  Runpose
//
//  Created by DennisChiu on 16/3/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Foundation

class SignupPage: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var spinner = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spinner.style = .gray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    
        
        
    }
    
    @IBAction func signup(_ sender: Any)  {
        if let email = emailTextField.text,let password = passwordTextField.text,let username = usernameTextField.text,let user = usernameTextField.text{

            if email == "" || password == "" || user == ""{
                
                let alertController = UIAlertController(title: "Error", message: "Please enter your email,password and username", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                
            }else{
                self.spinner.startAnimating()

                Auth.auth().createUser(withEmail: email, password: password) { (provider, error) in
                    
                    if error == nil{
                        print("changeReequest123456")
                        let alertController = UIAlertController(title: "Welcome", message: "You are successful", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                        self.spinner.stopAnimating()
                        
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.displayName = email
                        changeRequest!.commitChanges{ error in
                            if error == nil{
                                self.saveProfile(email: email, username: username){success in
                                    if success{
                                        print("ok successed")
                                        let gobacklogin = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
                                        self.present(gobacklogin, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }else{
                        
                        self.spinner.stopAnimating()
                        let alertController = UIAlertController(title: "Error", message:
                            error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func displayMyAlertMessage(userMessage:String){
        
        var myAlert = UIAlertController(title:"Alert",message: userMessage, preferredStyle: UIAlertController.Style.alert);
        
        let okAction = UIAlertAction(title:"OK" , style: UIAlertAction.Style.default, handler:nil);
        
        myAlert.addAction(okAction);
        
        self.present(myAlert, animated: true, completion:nil);
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func saveProfile(email:String, username:String, completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/account/\(uid)")
        
        let userObject = [
            "email": email,
            "username": username,
            ] as [String:Any]
        
        
        databaseRef.setValue(userObject){error, ref in
            completion(error == nil)
        }

    }
    
}

