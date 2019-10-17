//
//  HomePage.swift
//  Runpose
//
//  Created by DennisChiu on 16/3/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Firebase
import HealthKit

class HomePage: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {


    @IBAction func backtoHomepage(segue : UIStoryboardSegue){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(_ animated: Bool) {

        let user = Auth.auth().currentUser

        if(user == nil){
            self.performSegue(withIdentifier: "loginView",sender: self);
        }
        
        let imageView = UIImageView(frame: CGRect(x:0,y:0,width:90,height:20))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "taijifont.png")
        imageView.image = image
        
        navigationItem.titleView = imageView
        
        
    }
    
    
//    func readEnergy() {
//        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
//            print("Sample type not available")
//            return
//        }
//
//        let now = Date()
//        let startOfDay = Calendar.current.startOfDay(for: now)
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
//
//        let energyQuery = HKSampleQuery(sampleType: energyType,predicate: predicate,limit: HKObjectQueryNoLimit,sortDescriptors: nil) {(query, sample, error) in
//            guard error == nil,let quantitySamples = sample as? [HKQuantitySample] else {
//                print("Something went wrong: \(error)")
//                return
//
//            }
//            let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
//            print("Total kcal: \(total)")
//
//            DispatchQueue.main.async {
//                self.energyLabel.text = String(format: "%.2f", total)
//            }
//            let EnergyRequest  = Auth.auth().currentUser?.createProfileChangeRequest()
//            EnergyRequest?.displayName = String(total)
//            let energy  = String(total)
//
//            EnergyRequest!.commitChanges{ error in
//                if error == nil{
//                    guard let uid = Auth.auth().currentUser?.uid else{ return }
//
//                    let databaseRef = Database.database().reference().child("users/account/\(uid)")
//                    let EnergyObject = ["Energy": energy,] as [String:Any]
//
//                    databaseRef.updateChildValues(EnergyObject)
//                }
//            }
//        }
//        HKHealthStore().execute(energyQuery)
//    }
//
}
