//
//  SuggestionPage.swift
//  Runpose
//
//  Created by Yiu Lik Ngai on 20/4/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//let imageCache = NSCache<NSString, AnyObject>()
class SuggestionPage: UIViewController {
    
    let formatter = DateFormatter()
    var rArmAngle : Double = 0.0
    var lArmAngle : Double = 0.0
    var rKneeAngle : Double = 0.0
    var lKneeAngle : Double = 0.0
    var bodyAngle : Double = 0.0
    var twoArmAngle : Double = 0.0
    var twoLegAngle : Double = 0.0
    
    var rarmSuggest : String = ""
    var larmSuggest : String = ""
    var rkneeSuggest : String = ""
    var lkneeSuggest : String = ""
    var bodySuggest : String = ""
    var twoArmSuggest : String = ""
    var twoLegSuggest : String = ""
    
    @IBOutlet var rarmSuggestLabel: UILabel!
    @IBOutlet var larmSuggestLabel: UILabel!
    @IBOutlet var twoArmSuggestLabel: UILabel!
    @IBOutlet var twoLegSuggestLabel: UILabel!
    @IBOutlet var bodySuggestLabel: UILabel!
    
    
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        if let user = Auth.auth().currentUser {
            uid = user.uid
        }
        
        print(" rAam \(rArmAngle) \n lArm \(lArmAngle) \n rKnee \(rKneeAngle) \n lKnee \(lKneeAngle) \n body \(bodyAngle)")
        photoAnalysis()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        uploadImage()
    }
    func uploadImage(){
        let imageName = NSUUID().uuidString
        var screenshot = captureScreenshot()

        let storageRef = Storage.storage().reference().child("users/account/\(uid)/images").child("\(imageName).png")
        
        print("screenshot")
        if let uploadData = screenshot.pngData() {
            print("screenshot1")
            storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
                
                if let error = err {
                    print(error)
                    return
                }
                
                storageRef.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    
                    guard let url = url else { return }
                    
                    let values = ["\(self.formatter.string(from: Date()))": url.absoluteString]
                    
                    print("testing:\(values)")
                    
                    self.registerUserIntoDatabaseWithUID(self.uid, values: values as [String : AnyObject])

                })
                
            })
        }
    }
    
    func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference(fromURL:"https://loginbase-9ca27.firebaseio.com/")
        let usersReference = ref.child("users/account/\(uid)").child("images")
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            
            //self.dismiss(animated: true, completion: nil)
        })
    }
    
    func captureScreenshot() -> UIImage{
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        // Creates UIImage of same size as view
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot!
    }
    
    

    func photoAnalysis() {
        switch rArmAngle {
        case 0:
            rarmSuggestLabel.text = "Didn't detect"
        case 80...100:
            rarmSuggestLabel.text = "Your posture is correct."
        case 1...79, 101...180:
            rarmSuggestLabel.text = "The arm should flexes approximately 90 degrees."
        default:
            break;
        }
        
        switch lArmAngle {
        case 0:
            larmSuggestLabel.text = "Didn't detect"
        case 80...100:
            larmSuggestLabel.text = "Your posture is correct."
        case 1...79, 101...180:
            larmSuggestLabel.text = "The arm should flexes approximately 90 degrees."
        default:
            break;
        }
        
        switch twoArmAngle {
        case 0:
            twoArmSuggestLabel.text = "Didn't detect"
        case 1...90:
            twoArmSuggestLabel.text = "Your posture is correct."
        case 91...180:
            twoArmSuggestLabel.text = "The angle of Swinging arm should below 90 degrees."
        default:
            break;
        }
        
        switch twoLegAngle {
        case 0:
            twoLegSuggestLabel.text = "Didn't detect"
        case 1...80:
            twoLegSuggestLabel.text = "Your posture is correct."
        case 81...180:
            twoLegSuggestLabel.text = "The angle between two legs should lower than 80 degrees."
        default:
            break;
        }
        
        switch bodyAngle {
        case 0:
            bodySuggestLabel.text = "Didn't detect"
        case 80...95:
            bodySuggestLabel.text = "Your posture is correct."
        case 1...79:
            bodySuggestLabel.text = "Your body keep leaning forward, you should keep your body straight."
        case 96...180:
            bodySuggestLabel.text = "Your body keep leaning back, you should keep your body straight."
        default:
            break;
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
