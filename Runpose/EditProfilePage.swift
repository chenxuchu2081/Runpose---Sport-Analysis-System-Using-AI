//
//  EditProfilePageViewController.swift
//  Runpose
//
//  Created by DennisChiu on 10/4/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit
import HealthKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class EditProfilePage: UIViewController{

    @IBOutlet weak var EdituserTextField: UITextField!
    @IBOutlet weak var EditweightTextField: UITextField!
    @IBOutlet weak var EditheightTextField: UITextField!
    @IBOutlet weak var EditgenderTextField: UITextField!
    
    
    let uid : String = (Auth.auth().currentUser?.uid)!
    let healthStore = HKHealthStore()

    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        let height = EditheightTextField.text
        let weight = EditweightTextField.text
        let username = EdituserTextField.text
        let gender  = EditgenderTextField.text
        
        if username != "" || height != "" || weight != "" || gender != "" {
            let DistanceRequest  = Auth.auth().currentUser?.createProfileChangeRequest()
            DistanceRequest?.displayName = self.EdituserTextField.text
            DistanceRequest?.displayName = self.EditgenderTextField.text
            DistanceRequest?.displayName = self.EditweightTextField.text
            DistanceRequest?.displayName = self.EditheightTextField.text

            let UsernameChange = self.EdituserTextField.text
            let genderChange = self.EditgenderTextField.text
            let heightChange = self.EditheightTextField.text
            let weightChange = self.EditweightTextField.text


            DistanceRequest!.commitChanges{ error in
                if error == nil{
                    guard let uid = Auth.auth().currentUser?.uid else{ return }
                    
                    let databaseRef = Database.database().reference().child("users/account/\(uid)")
                    let DistanceObject = ["username": UsernameChange!,
                                          "Height":heightChange!,
                                          "Weight": weightChange!,
                                          "Gender": genderChange!,
                                          ] as [String:Any]
                    
                    databaseRef.updateChildValues(DistanceObject)
                }
            }
        }

        self.dismiss(animated: true, completion:nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refusername = Database.database().reference(withPath: "users/account/\(uid)/username")
        refusername.observe(.value, with: { (snapshot) in
            print (snapshot.value as Any)
            for child in snapshot.children{
                if let snapshot = child as? DataSnapshot{
                    print("snapshot > datasnapshot")
                }
            }
            self.EdituserTextField.text = snapshot.value as Any as? String
        })
        
        let refgender = Database.database().reference(withPath: "users/account/\(uid)/Gender")
        refgender.observe(.value, with: { (snapshot) in
            print (snapshot.value as Any)
            for child in snapshot.children{
                if let snapshot = child as? DataSnapshot{
                    print("snapshot > datasnapshot")
                }
            }
            self.EditgenderTextField.text = snapshot.value as Any as? String
        })
        
        let refheight = Database.database().reference(withPath: "users/account/\(uid)/Height")
        refheight.observe(.value, with: { (snapshot) in
            print (snapshot.value as Any)
            for child in snapshot.children{
                if let snapshot = child as? DataSnapshot{
                    print("snapshot > datasnapshot")
                }
            }
            self.EditheightTextField.text = snapshot.value as Any as? String
        })
        
        let refweight = Database.database().reference(withPath: "users/account/\(uid)/Weight")
        refweight.observe(.value, with: { (snapshot) in
            print (snapshot.value as Any)
            for child in snapshot.children{
                if let snapshot = child as? DataSnapshot{
                    print("snapshot > datasnapshot")
                }
            }
            self.EditweightTextField.text = snapshot.value as Any as? String
        })
        
    }
    
//    func writeHeightProfile(){
//        let Height = Double(self.EditheightTextField.text!)
//
//        let inchUnit = HKUnit.meterUnit(with: .centi)
//        let heightQuantity = HKQuantity(unit: inchUnit, doubleValue: Height!)
//
//        let heightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
//        let nowDate = Date()
//
//        let heightSample = HKQuantitySample(type: heightType, quantity: heightQuantity, start: nowDate, end: nowDate)
//
//        healthStore.save(heightSample, withCompletion: {(sucuess,error)in
//            print("Save \(sucuess), error,\(error)")
//        })
//
//    }
//
//    //Weight edit
//    func writeWeightProfile(){
//        let Weight = Double(self.EditweightTextField.text!)
//
//        let weightUnit = HKUnit.pound()
//        let weightQuantity = HKQuantity(unit: weightUnit, doubleValue: Weight!)
//
//        let weightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
//        let nowDate = Date()
//
//        let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: nowDate, end: nowDate)
//
//        healthStore.save(weightSample, withCompletion: {(sucuess,error)in
//            print("Save \(sucuess), error,\(error)")
//        })
//
//    }
//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
