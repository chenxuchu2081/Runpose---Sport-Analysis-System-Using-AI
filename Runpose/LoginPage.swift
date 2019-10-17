//
//  LoginPage.swift
//  Runpose
//
//  Created by DennisChiu on 16/3/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit
import FirebaseAuth
import HealthKit
class LoginPage: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        var healthStore = HKHealthStore()
     var spinner = UIActivityIndicatorView()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPermission()
        
        spinner.style = .gray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])

    }
    
    func getPermission() {
        if HKHealthStore.isHealthDataAvailable(){
        }
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let weight = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let footstep = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            let energy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)else{
                print("error")
                return
        }
        
        let healthKitTypesToWrite: Set<HKSampleType> = [height,weight]
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       height,
                                                       weight,
                                                       distance,
                                                       energy,
                                                       footstep,
                                                       HKObjectType.workoutType()]
        
        self.healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            if !success {
                // Handle the error here
                print(error?.localizedDescription)
            }
        }
    }

    @IBAction func backToLogin(segue : UIStoryboardSegue){
        
    }
    
    @IBAction func login(_ sender: Any) {
        if let emailLogin = emailTextField.text, let passwordLogin = passwordTextField.text{
            
            //            Auth.auth().signIn(withEmail: emailLogin, password: passwordLogin, completion: {(user, error) in
            //
            //                if let firebaseError = error{
            //                    print(firebaseError.localizedDescription)
            ////                       self.displayMyAlertMessage(userMessage: "Fail")
            //                    return
            //                }
            //
            //
            //                print("successful login function")
            //
            //            })
            
            if emailLogin == "" || passwordLogin == "" {
                
                let alertController = UIAlertController(title: "Alert", message: "Please enter an email and password.", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                
                self.spinner.startAnimating()
                
                Auth.auth().signIn(withEmail: emailLogin, password: passwordLogin) { (provider, error) in
                    
                    if error == nil {
                        
                        self.spinner.stopAnimating()
                        
                        // 登入成功，打印 ("You have successfully logged in")
                        //                        self.spinner.startAnimating()
                        
                        //Go to the HomeViewController if the login is sucessful
                        
                        self.performSegue(withIdentifier: "tohomepage", sender: self)
                        
                        
                        
                    } else {
                        
                        self.spinner.stopAnimating()
                        
                        // 提示用戶從 firebase 返回了一個錯誤。
                        let alertController = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: .alert)
                        
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if let user = Auth.auth().currentUser {
            self.performSegue(withIdentifier: "tohomepage", sender: self)
        }
    }
}


