//
//  SignupInfoPage.swift
//  Runpose
//
//  Created by DennisChiu on 16/4/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class SignupInfoPage: UIViewController {

    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
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
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signup(_ sender: Any) {
        if let gender = genderTextField.text,let height = heightTextField.text,let weight = weightTextField.text{
            
            if gender == "" || height == "" || weight == ""{
                
                let alertController = UIAlertController(title: "Error", message: "Please complete your profile", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                
            }else{
                self.spinner.startAnimating()
                
                let EnergyRequest  = Auth.auth().currentUser?.createProfileChangeRequest()
                EnergyRequest?.displayName = gender
                EnergyRequest?.displayName = height
                EnergyRequest?.displayName = weight
                
                EnergyRequest!.commitChanges{ error in
                    if error == nil{
                        
                        self.spinner.stopAnimating()

                        guard let uid = Auth.auth().currentUser?.uid else{ return }
                        
                        let databaseRef = Database.database().reference().child("users/account/\(uid)")
                        let EnergyObject = ["Height": height,
                                            "Weight": weight,
                                            "Gender":gender] as [String:Any]
                        
                        databaseRef.updateChildValues(EnergyObject)
                        
                        let gobacklogin = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
                        self.present(gobacklogin, animated: true, completion: nil)
                        
                    }

                }
            }
        }
    }

//                            print("changeReequest123456")
//                            if error == nil{
//                                print("is okokokokokok")
//                                self.saveProfile(gender: gender, weight: weight, height: height,completion: {success in
//                                    if success{
//                                        print("ok successed")
//                                        self.dismiss(animated: true, completion:nil);
//
//                                    }
//                                }
//                            }
//                        }else{
//                        self.spinner.stopAnimating()
//                        let alertController = UIAlertController(title: "Error", message:
//                            error?.localizedDescription, preferredStyle: .alert)
//                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//
//                        alertController.addAction(defaultAction)
//
//                        self.present(alertController, animated: true, completion: nil)
//                    }
//
//            }
//        }
//    }
            
     

    
    
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
    
   func saveProfile(gender:String, weight:String, height:String, completion: @escaping ((_ success:Bool)->())) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let databaseRef = Database.database().reference().child("users/account/\(uid)")
            
            let userObject = [
                "Gender": gender,
                "Weight": weight,
                "Height": height
                ] as [String:Any]
            
            
            databaseRef.setValue(userObject){error, ref in
                completion(error == nil)
            }
            
        }

}
