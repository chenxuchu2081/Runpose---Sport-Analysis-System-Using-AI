//
//  RealtimeSuggestPage.swift
//  Runpose
//
//  Created by Yiu Lik Ngai on 21/4/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit

class RealtimeSuggestPage: UIViewController {

    var rArmAngleArray = [Double]()
    var lArmAngleArray = [Double]()
    var rKneeAngleArray = [Double]()
    var lKneeAngleArray = [Double]()
    var bodyAngleArray = [Double]()
    var twoArmAngleArray = [Double]()
    var twoLegAngleArray = [Double]()
    
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
    
    @IBOutlet var rarmAngleLabel: UILabel!
    @IBOutlet var larmAngleLabel: UILabel!
    @IBOutlet var twoArmAngleLabel: UILabel!
    @IBOutlet var twoLegAngleLabel: UILabel!
    @IBOutlet var bodyAngleLabel: UILabel!
    

    var minRArm : Double = 0.0
    var minLArm : Double = 0.0
    var minTwoArm : Double = 0.0
    var minTwoLeg : Double = 0.0
    var minBody : Double = 0.0
    
    var maxRArm : Double = 0.0
    var maxLArm : Double = 0.0
    var maxTwoArm : Double = 0.0
    var maxTwoLeg : Double = 0.0
    var maxBody : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(" rAam \(rArmAngleArray) \n lArm \(lArmAngleArray) \n rKnee \(rKneeAngleArray) \n lKnee \(lKneeAngleArray) \n body \(bodyAngleArray) \n twoLeg \(twoLegAngleArray) \n twoArm \(twoArmAngleArray)")
        checkEmpty()
        getMin()
        getMax()
        setLabel()
        analysis()
        
        
//        print(" rAam \(rArmAngle) \n lArm \(lArmAngle) \n rKnee \(rKneeAngle) \n lKnee \(lKneeAngle) \n body \(bodyAngle)")
//        analysis()
        // Do any additional setup after loading the view.
    }
    
    func checkEmpty() {
        if rArmAngleArray.isEmpty {
            rArmAngleArray.append(-1)
        }
        if lArmAngleArray.isEmpty {
            lArmAngleArray.append(-1)
        }
        if twoArmAngleArray.isEmpty {
            twoArmAngleArray.append(-1)
        }
        if twoLegAngleArray.isEmpty {
            twoLegAngleArray.append(-1)
        }
        if bodyAngleArray.isEmpty {
            bodyAngleArray.append(-1)
        }
    }
    
    func getMin() {
        minRArm = rArmAngleArray[0]
        minLArm = lArmAngleArray[0]
        minTwoArm = twoArmAngleArray[0]
        minTwoLeg = twoLegAngleArray[0]
        minBody = bodyAngleArray[0]

        for rArm in rArmAngleArray {
            if ((rArm < minRArm) && (rArm != 0)){
                minRArm = rArm
            }
        }
        
        for lArm in lArmAngleArray {
            if ((lArm < minLArm) && (lArm != 0)) {
                minLArm = lArm
            }
        }
        
        for twoArm in twoArmAngleArray {
            if twoArm < minTwoArm {
                minTwoArm = twoArm
            }
        }
        
        for twoLeg in twoLegAngleArray {
            if twoLeg < minTwoLeg {
                minTwoLeg = twoLeg
            }
        }
        
        for body in bodyAngleArray {
            if ((body < minBody) && (body != 0)) {
                minBody = body
            }
        }
    }
    
    func getMax() {
        maxRArm = rArmAngleArray[0]
        maxLArm = lArmAngleArray[0]
        maxTwoArm = twoArmAngleArray[0]
        maxTwoLeg = twoLegAngleArray[0]
        maxBody = bodyAngleArray[0]
        
        for rArm in rArmAngleArray {
            if rArm > maxRArm {
                maxRArm = rArm
            }
        }
        
        for lArm in lArmAngleArray {
            if lArm > maxLArm {
                maxLArm = lArm
            }
        }
        
        for twoArm in twoArmAngleArray {
            if twoArm > maxTwoArm {
                maxTwoArm = twoArm
            }
        }
        
        for twoLeg in twoLegAngleArray {
            if twoLeg > maxTwoLeg {
                maxTwoLeg = twoLeg
            }
        }
        
        for body in bodyAngleArray {
            if body > maxBody {
                maxBody = body
            }
        }

    }
    
    
    func setLabel() {
        if minRArm != -1 && maxRArm != -1 {
            rarmAngleLabel.text = "\(minRArm)° - \(maxRArm)°"
        } else {
            rarmAngleLabel.text = ""
        }
        
        if minLArm != -1 && maxLArm != -1 {
            larmAngleLabel.text = "\(minLArm)° - \(maxLArm)°"
        } else {
            larmAngleLabel.text = ""
        }
        
        if minTwoArm != -1 && maxTwoArm != -1 {
            twoArmAngleLabel.text = "\(minTwoArm)° - \(maxTwoArm)°"
        } else {
            twoArmAngleLabel.text = ""
        }
        
        if minTwoLeg != -1 && maxTwoLeg != -1 {
            twoLegAngleLabel.text = "\(minTwoLeg)° - \(maxTwoLeg)°"
        } else {
            twoLegAngleLabel.text = ""
        }
        
        if minBody != -1 && maxBody != -1 {
            bodyAngleLabel.text = "\(minBody)° - \(maxBody)°"
        } else {
            bodyAngleLabel.text = ""
        }
        
    
    }
    
    func analysis() {
        var bodyLeanF = false
        var rArmCorrect = true
        var lArmCorrect = true
        var twoArmCorrect = true
        var twoLegCorrect = true
        var bodyCorrect = true
        
        switch minRArm {
        case 80...100:
            rarmSuggestLabel.text = "Your posture is correct."
        case 0...79, 101...180:
            rarmSuggestLabel.text = "The arm should flexes approximately 90 degrees."
            rArmCorrect = false
        case -1:
            rarmSuggestLabel.text = "Didn't detect"
        default:
            break;
        }
        
        switch maxRArm {
        case 80...100:
            if rArmCorrect {
                rarmSuggestLabel.text = "Your posture is correct."
            }
        case 0...79, 101...180:
            rarmSuggestLabel.text = "The arm should flexes approximately 90 degrees."
        case -1:
            rarmSuggestLabel.text = "Didn't detect"
        default:
            break;
        }

        switch minLArm {
        case 80...100:
            larmSuggestLabel.text = "Your posture is correct."
        case 0...79, 101...180:
            larmSuggestLabel.text = "The arm should flexes approximately 90 degrees."
            lArmCorrect = false
        case -1:
            larmSuggestLabel.text = "Didn't detect"
        default:
            break;
        }
        
        switch maxLArm {
        case 80...100:
            if lArmCorrect {
                larmSuggestLabel.text = "Your posture is correct."
            }
            
        case 0...79, 101...180:
            larmSuggestLabel.text = "The arm should flexes approximately 90 degrees."
        case -1:
            larmSuggestLabel.text = "Didn't detect"
        default:
            break;
        }

        switch minTwoArm {
        case 0...90:
            twoArmSuggestLabel.text = "Your posture is correct."
        case 91...180:
            twoArmSuggestLabel.text = "The angle of Swinging arm should below 90 degrees."
            twoArmCorrect = false
        case -1:
            twoArmSuggestLabel.text = "Didn't detect"
        default:
            break;
        }

        switch maxTwoArm {
        case 0...90:
            if twoArmCorrect {
                twoArmSuggestLabel.text = "Your posture is correct."
            }
        case 91...180:
            twoArmSuggestLabel.text = "The angle of Swinging arm should below 90 degrees."
        case -1:
            twoArmSuggestLabel.text = "Didn't detect"
        default:
            break;
        }
        
    
        switch minTwoLeg {
        case 0...80:
            twoLegSuggestLabel.text = "Your posture is correct."
        case 81...180:
            twoLegSuggestLabel.text = "The angle between two legs should lower than 80 degrees."
            twoLegCorrect = false
        case -1:
            twoLegSuggestLabel.text = "Didn't detect"
        default:
            break;
        }
        
        switch maxTwoLeg {
        case 0...80:
            if twoLegCorrect {
                twoLegSuggestLabel.text = "Your posture is correct."
            }
        case 81...180:
            twoLegSuggestLabel.text = "The angle between two legs should lower than 80 degrees."
        case -1:
            twoLegSuggestLabel.text = "Didn't detect"
        default:
            break;
        }

        switch minBody {
        case 80...95:
            bodySuggestLabel.text = "Your posture is correct."
        case 0...79:
            bodyLeanF = true
            bodyCorrect = false
            bodySuggestLabel.text = "Your body keep leaning forward, you should keep your body straight."
        case 96...180:
            bodyCorrect = false
            bodySuggestLabel.text = "Your body keep leaning back, you should keep your body straight."
        case -1:
            bodySuggestLabel.text = "Didn't detect"
        default:
            break;
        }
        
        switch maxBody {
        case 80...95:
            if bodyCorrect {
                bodySuggestLabel.text = "Your posture is correct."
            }
        case 0...79:
            bodySuggestLabel.text = "Your body keep leaning forward, you should keep your body straight."
        case 96...180:
            if bodyLeanF {
                bodySuggestLabel.text = "Your body keep leaning forward and back, you should keep your body straight."
            } else {
                bodySuggestLabel.text = "Your body keep leaning back, you should keep your body straight."
            }
        case -1:
            bodySuggestLabel.text = "Didn't detect"
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
