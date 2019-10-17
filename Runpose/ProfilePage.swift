//
//  ProfilePage.swift
//  Runpose
//
//  Created by DennisChiu on 28/3/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Firebase
import HealthKit

class ProfilePage: UIViewController {
    
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var BloodTypeLabel: UILabel!
    @IBOutlet weak var BirthDateLabel: UILabel!
    @IBOutlet weak var HeightLabel: UILabel!
    @IBOutlet weak var WeightLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    var healthStore = HKHealthStore()
    
    let userID : String = (Auth.auth().currentUser?.uid)!

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func readData(){
        self.ReadUserAge()
        
        let(bloodtype) = self.readBlood()
        self.BloodTypeLabel.text = self.getReadablebloodType(bloodType: bloodtype?.bloodType ?? .notSet)
        self.readDate()

//        self.readStep()
//        self.readDistanceWalkAndRun()
//        self.readHeight()
//        self.readWeight()
//        let(sextype) = self.readsex()
//        self.sexLabel.text = self.getbiologcalSex(sexType: (sextype?.biologicalSex ?? .notSet))
//        self.readEnergy()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.readData()
        
        //read blood,age
        let blood = self.BloodTypeLabel.text
        let age = self.ageLabel.text
        
        let changeRequest  = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = blood
        changeRequest?.displayName = age
        
        changeRequest!.commitChanges{ error in
            if error == nil{
                self.saveHealthProfile(Age: age!, bloodtype: blood!){success in
                    if success{
                        print("ok successed")
                    }else{
                        return
                    }
                }
            }
        }
        
        //read database user username
        let ref = Database.database().reference(withPath: "users/account/\(userID)/username")
        ref.observe(.value, with: { (snapshot) in
            print (snapshot.value as Any)
            for child in snapshot.children{
                if let snapshot = child as? DataSnapshot{
                    print("snapshot > datasnapshot")
                }
            }
            self.Username.text = snapshot.value as Any as? String
            self.Username.isHidden = false
        })
        
        //read database user Email
        let refemail = Database.database().reference(withPath: "users/account/\(userID)/email")
        print(refemail)
        refemail.observe(.value, with: { (snapshot) in
            print (snapshot.value as Any)
            for child in snapshot.children{
                if let snapshot = child as? DataSnapshot{
                    print("snapshot > datasnapshot")
                }
            }
            self.emailLabel.text = snapshot.value as Any as? String
            self.emailLabel.isHidden = false
        })
        
        //read database user weight
        let refweight = Database.database().reference(withPath: "users/account/\(userID)/Weight")
        refweight.observe(.value, with: { (snapshot) in
            print (snapshot.value as Any)
            for child in snapshot.children{
                if let snapshot = child as? DataSnapshot{
                    print("snapshot > datasnapshot")
                }
            }
            self.WeightLabel.text = snapshot.value as Any as? String
            self.WeightLabel.isHidden = false
        })

        //read database user height
        let refheight = Database.database().reference(withPath: "users/account/\(userID)/Height")
        refheight.observe(.value, with: { (snapshot) in
            print (snapshot.value as Any)
            for child in snapshot.children{
                if let snapshot = child as? DataSnapshot{
                    print("snapshot > datasnapshot")
                }
            }
            self.HeightLabel.text = snapshot.value as Any as? String
            self.HeightLabel.isHidden = false
        })
        
        //read database user gender
        let refgender = Database.database().reference(withPath: "users/account/\(userID)/Gender")
        refgender.observe(.value, with: { (snapshot) in
            print (snapshot.value as Any)
            for child in snapshot.children{
                if let snapshot = child as? DataSnapshot{
                    print("snapshot > datasnapshot")
                }
            }
            self.sexLabel.text = snapshot.value as Any as? String
            self.sexLabel.isHidden = false
        })
    }
    
    
    @IBAction func logout(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            let logoutBT = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
            present(logoutBT, animated: true, completion: nil)
        }catch{
            print("there was a problem to logout")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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

        healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            if !success {
                // Handle the error here
                print(error?.localizedDescription)
            }
        }
    }
    
    @IBAction func backtoProfile(segue : UIStoryboardSegue){
        
    }
    

//    Read energy,step,distance
    
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
//                self.EnergyLabel.text = String(format: "Energy: %.2f", total)
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
//    func readStep(){
//        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//
//        let now = Date()
//        let startOfDay = Calendar.current.startOfDay(for: now)
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
//
//        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
//            var resultCount = 0.0
//
//            guard let result = result else {
//                print("Failed to fetch steps rate")
//                self.FootStepLabel.text = "\(resultCount)"
//                return
//            }
//            if let sum = result.sumQuantity() {
//                resultCount = sum.doubleValue(for: HKUnit.count())
//            }
//            print(resultCount)
//            DispatchQueue.main.async {
//                self.FootStepLabel.text = "\(resultCount)"
//            }
//
//            let StepRequest  = Auth.auth().currentUser?.createProfileChangeRequest()
//            StepRequest?.displayName = String("\(resultCount)")
//            let step  = String("\(resultCount)")
//
//            StepRequest!.commitChanges{ error in
//                if error == nil{
//                    guard let uid = Auth.auth().currentUser?.uid else{ return }
//
//                    let databaseRef = Database.database().reference().child("users/account/\(uid)")
//                    let StepObject = ["Step": step,] as [String:Any]
//
//                    databaseRef.updateChildValues(StepObject)
//                }
//            }
//        }
//        healthStore.execute(query)
//
//    }
//
//    func readDistanceWalkAndRun(){
//        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
//
//        let now = Date()
//        let startOfDay = Calendar.current.startOfDay(for: now)
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
//
//        let distancequery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
//            var Count = 0.0
//
//            guard let result = result else {
//                print("Failed to fetch steps rate")
//                return
//            }
//            if let sum = result.sumQuantity() {
//                Count = sum.doubleValue(for: HKUnit.meter())
//            }
//            print(Count)
//
//            DispatchQueue.main.async {
//                self.DistanceRunAndWalkLabel.text = String(format: "Distance: %.2f", Count/1000)
//            }
//
//            let DistanceRequest  = Auth.auth().currentUser?.createProfileChangeRequest()
//            DistanceRequest?.displayName = String(Count/1000)
//            let Distance  = String(Count/1000)
//
//            DistanceRequest!.commitChanges{ error in
//                if error == nil{
//                    guard let uid = Auth.auth().currentUser?.uid else{ return }
//
//                    let databaseRef = Database.database().reference().child("users/account/\(uid)")
//                    let DistanceObject = ["Distance": Distance,] as [String:Any]
//
//                    databaseRef.updateChildValues(DistanceObject)
//                }
//            }
//        }
//        healthStore.execute(distancequery)
//    }
    

    //read age
    func ReadUserAge() -> Void
    {
        var dateOfBirth: Date! = nil
        
        do {
            dateOfBirth = try self.healthStore.dateOfBirth()
        } catch {
            print("Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.")
            return
        }
        
        let now = Date()
        
        let ageComponents: DateComponents = Calendar.current.dateComponents([.year], from: dateOfBirth, to: now)
        
        let userAge: Int = ageComponents.year!
        
        let ageValue: String = NumberFormatter.localizedString(from: userAge as NSNumber, number: NumberFormatter.Style.none)
        
        self.ageLabel.text = "( \(ageValue) years old )"
    }
    
    //read Date
    func readDate(){
        do{
            let dobComponent = try healthStore.dateOfBirthComponents()
            
            DispatchQueue.main.async {
                self.BirthDateLabel.text = "Date Of Birth: \(dobComponent.day!)/\(dobComponent.month!)/\(dobComponent.year!)"
            }
        }catch{
            
        }
    }

    func getbiologcalSex(sexType:HKBiologicalSex)-> String{
        
        var sexText = "";
        
        if sexType != nil{
            switch (sexType) {
            case .female:
                return "Female"
            case .male:
                return "Male"
            case .notSet:
                return "Not Set"
            default:
                break;
                
            }
        }
        return sexText
    }
    
    //read bloodtype
    func readBlood() -> (HKBloodTypeObject?){
        var blooType:HKBloodTypeObject?
        
        //bloodType
        do{
            blooType = try healthStore.bloodType()
        }catch{}
        
        return(blooType)
    }
    
    func getReadablebloodType(bloodType:HKBloodType?)->String{
        
        var bloodTypeText = "";
        
        if bloodType != nil{
            
            switch ( bloodType! ){
            case .aPositive:
                bloodTypeText = "A+"
            case .aNegative:
                bloodTypeText = "A-"
            case .bPositive:
                bloodTypeText = "B+"
            case .bNegative:
                bloodTypeText = "B-"
            case .abPositive:
                bloodTypeText = "AB+"
            case .abNegative:
                bloodTypeText = "AB-"
            case .oPositive:
                bloodTypeText = "O+"
            case .oNegative:
                bloodTypeText = "O-"
            case .notSet:
                bloodTypeText = "Not set"
                
            default:
                break;
            }
        }
        return bloodTypeText
    }

    
    
    func saveHealthProfile(Age:String, bloodtype:String,completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/account/\(uid)")

        let userObject = [
            "Age":Age,
            "Bloodtype": bloodtype,
           
            ] as [String:Any]
        
        databaseRef.updateChildValues(userObject){error, ref in
            completion(error == nil)
        }
        
    }
    
    func testsave(Weight:String,completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/account/\(uid)")
        
        let userObject = [
            "Weight": Weight,
            ] as [String:Any]
      
        databaseRef.updateChildValues(userObject){error, ref in
            completion(error == nil)
            print("updataChild")
        }
        
    }
}

//    //readheight
//    func readHeight(){
//        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
//
//        let heightquery = HKSampleQuery(sampleType: heightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {
//            (heightquery, results, error) in
//
//            if let result = results?.last as? HKQuantitySample{
//                print("height => \(result.quantity)")
//                DispatchQueue.main.async(execute: {()->Void in
//                    self.HeightLabel.text = "\(result.quantity)"
//                });
//
//                let changeRequest1  = Auth.auth().currentUser?.createProfileChangeRequest()
//
//                changeRequest1?.displayName = "\(result.quantity)"
//                let test  = String("\(result.quantity)")
//
//                changeRequest1!.commitChanges{ error in
//                    print("savesave")
//                    if error == nil{
//                        print("is okokokokokok")
//
//                        guard let uid = Auth.auth().currentUser?.uid else{return}
//                        let databaseRef = Database.database().reference().child("users/account/\(uid)")
//                        let userObject = ["Height": test,] as [String:Any]
//
//                        databaseRef.updateChildValues(userObject)
//                    }
//                }
//            }else{
//                print("cannot get height data \n\(String(describing: results)), error == \(String(describing:   error))")
//            }
//        }
//        healthStore.execute(heightquery)
//    }

//    func readWeight(){
//        let weightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
//
//        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {(query, results, error) in
//            if let result = results?.last as? HKQuantitySample{
//
//                print("weight => \(result.quantity)")
//                DispatchQueue.main.async{
//                    self.WeightLabel.text = "\(result.quantity)"
//                }
//                let changeRequest  = Auth.auth().currentUser?.createProfileChangeRequest()
//                changeRequest?.displayName = "\(result.quantity)"
//
//                changeRequest!.commitChanges{ error in
//                    if error == nil{
//                        self.testsave(Weight: String("\(result.quantity)")){success in
//                            if success{
//                                print("ok successed save weight")
//                            }
//                        }
//                    }
//                }
//            }else{
//                print("cannot get height data \n\(String(describing: results)), error == \(String(describing:   error))")
//            }
//        }
//        healthStore.execute(query)
//    }
//


