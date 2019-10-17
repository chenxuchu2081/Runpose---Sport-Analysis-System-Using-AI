//
//  ViewController.swift
//  Runpose
//
//  Created by DennisChiu on 15/3/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit
import CoreML
import AVKit
import Vision
import AVFoundation


class ViewController: UIViewController,UIPopoverPresentationControllerDelegate {
    
    
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var preview: UIImageView!
    var image : NSData?
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet var relbowLabel: UILabel!
    @IBOutlet var lelbowLabel: UILabel!
    @IBOutlet var rkneeLabel: UILabel!
    @IBOutlet var lkneeLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var twoArmLabel: UILabel!
    @IBOutlet var twoLegLabel: UILabel!
    @IBOutlet var angleView: UIView!
    
    var rArmAngle : Double = 0.0
    var lArmAngle : Double = 0.0
    var rKneeAngle : Double = 0.0
    var lKneeAngle : Double = 0.0
    var bodyAngle : Double = 0.0
    var twoArmAngle : Double = 0.0
    var twoLegAngle : Double = 0.0
    var abc : Double = 0.0
    
    @IBOutlet var showImageView: UIView!
    @IBOutlet var reliabilityLabel: UILabel!
    
    var context = CIContext(options: nil)
    
    let model = MobileOpenPose200()
    let ImageWidth = 200
    let ImageHeight = 200
    
    let semaphore = DispatchSemaphore(value: 1)
    
    let imagePicker = UIImagePickerController()
    // MARK: - Lifecycle Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        preview.frame = CGRect(x: (self.view.bounds.width - 300) / 2, y: preview.bounds.origin.y, width: 300, height: 300)
        
        myImage.frame = CGRect(x: (self.view.bounds.width - 300) / 2, y: preview.bounds.origin.y, width: 300, height: 300)
//        myImage.frame = CGRect(x: (showImageView.bounds.width - showImageView.bounds.height) / 2, y: 0, width: showImageView.bounds.height, height: showImageView.bounds.height)
//        preview.frame = CGRect(x: (showImageView.bounds.width - showImageView.bounds.height) / 2, y: 0, width: showImageView.bounds.height, height: showImageView.bounds.height)
//        angleView.frame = CGRect(x:10, y: (self.view.bounds.width + 10), width: (self.view.bounds.width - 20), height: self.view.bounds.height - self.view.bounds.width - 20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        myImage.image = UIImage(named: "blackpeople")
        if image != nil{
            myImage.image = UIImage.init(data: image! as Data)
        }
        runCoreML(myImage.image!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func runCoreML(_ image: UIImage) {
        //self.preview.image = image
        //return
        
        if let pixelBuffer = image.pixelBuffer(width: ImageWidth, height: ImageHeight) {
            if let prediction = try? model.prediction(image: pixelBuffer) {

                let predictionOutput = prediction.net_output
                let length = predictionOutput.count
                print("length: \(length)")
                //                print(predictionOutput)
                
                let doublePointer =  predictionOutput.dataPointer.bindMemory(to: Double.self, capacity: length)
                let doubleBuffer = UnsafeBufferPointer(start: doublePointer, count: length)
                let mm = Array(doubleBuffer)
                
                // Delete Beizer paths of previous image
                myImage.layer.sublayers = []
                
                // Draw new lines
                drawLines(mm)
            }
        }
    }
    
    // MARK: - Drawing
    
    func drawLines(_ mm: Array<Double>){
        
        let poseEstimator = PoseEstimator(ImageWidth,ImageHeight)
        var xyArray = [[Double]]()
        let res = measure(poseEstimator.estimate(mm))
        let humans = res.result;
        //        print("estimate \(res.duration)")
        var totalScore: Double = 0
        var totalPt: Int = 0
        var keypoint = [Int32]()
        var pos = [CGPoint]()
        for human in humans {
            var centers = [Int: CGPoint]()
            for i in 0...CocoPart.Background.rawValue {
                
                if human.bodyParts.keys.index(of: i) == nil {
                    xyArray.append([0.0, 0.0])
                    continue
                }
                let bodyPart = human.bodyParts[i]!
                print("Pose String: \(bodyPart.uidx)")
                print("Pose String: \(bodyPart.score)")
                totalScore += bodyPart.score
                totalPt += 1
                centers[i] = CGPoint(x: bodyPart.x, y: bodyPart.y)
                xyArray.append([Double(bodyPart.x),Double(bodyPart.y)])
                
            }
            
            for (pairOrder, (pair1,pair2)) in CocoPairsRender.enumerated() {
                
                if human.bodyParts.keys.index(of: pair1) == nil || human.bodyParts.keys.index(of: pair2) == nil {
                    keypoint.append(-1)
                    pos.append(CGPoint(x: 0.0, y: 0.0))
                    pos.append(CGPoint(x: 0.0, y: 0.0))
                    continue
                }
                if centers.index(forKey: pair1) != nil && centers.index(forKey: pair2) != nil{
                    keypoint.append(Int32(pairOrder))
                    pos.append(centers[pair1]!)
                    pos.append(centers[pair2]!)
                }
            }
        }
        
        let openCVWrapper = OpenCVWrapper()
        let drawLayer = CALayer()
        drawLayer.frame = myImage.bounds
        drawLayer.opacity = 0.6
        drawLayer.masksToBounds = true
        
        var angleSet : [Double] = []
        
        if totalPt != 0{
            let averageScore = Int((totalScore / Double(totalPt)) * 10)
            reliabilityLabel.text = String("\(averageScore)%")
            print("Score = \(averageScore)")
        }else{
            reliabilityLabel.text = "no people"
            relbowLabel.text = "Unknown"
            lelbowLabel.text = "Unknown"
            rkneeLabel.text = "Unknown"
            lkneeLabel.text = "Unknown"
            bodyLabel.text = "Unknown"
        }
        
        
        if keypoint.contains(2) && keypoint.contains(3){
            let dx1 = xyArray[3][0] - xyArray[2][0];
            let dy1 = xyArray[3][1] - xyArray[2][1];
            let dx2 = xyArray[3][0] - xyArray[4][0];
            let dy2 = xyArray[3][1] - xyArray[4][1];
            let angle1 = atan2(dy1,dx1)*180.0/Double.pi;
            let angle2 = atan2(dy2,dx2)*180.0/Double.pi;
            var rarmAngle = angle1 - angle2;
            rarmAngle = round(abs(rarmAngle))
            if (rarmAngle > 180) {
                rarmAngle = 360 - rarmAngle
            }
            
            if rarmAngle < 180 {
                let orientation = (xyArray[3][0]-xyArray[2][0])*(xyArray[4][1]-xyArray[2][1]) - (xyArray[3][1]-xyArray[2][1])*(xyArray[4][0]-xyArray[2][0])
                if orientation < 0 {
                    angleSet.append(rarmAngle)
                }else if orientation > 0{
                    angleSet.append(rarmAngle * -1)
                }else {
                    angleSet.append(-1000)
                }
            } else {
                angleSet.append(-1000)
            }
            
            print("The angle of right arm is \(rarmAngle)");
            self.relbowLabel.text = String("\(rarmAngle)°")
            rArmAngle = rarmAngle
        }else{
            angleSet.append(-1000)
        }
        
        if keypoint.contains(4) && keypoint.contains(5){
            let dx1 = xyArray[6][0] - xyArray[5][0];
            let dy1 = xyArray[6][1] - xyArray[5][1];
            let dx2 = xyArray[6][0] - xyArray[7][0];
            let dy2 = xyArray[6][1] - xyArray[7][1];
            let angle1 = atan2(dy1,dx1)*180.0/Double.pi;
            let angle2 = atan2(dy2,dx2)*180.0/Double.pi;
            var larmAngle = angle1 - angle2;
            larmAngle = round(abs(larmAngle))
            if (larmAngle > 180) {
                larmAngle = 360 - larmAngle
            }
            
            if larmAngle < 180 {
                let orientation = (xyArray[6][0]-xyArray[5][0])*(xyArray[7][1]-xyArray[5][1]) - (xyArray[6][1]-xyArray[5][1])*(xyArray[7][0]-xyArray[5][0])
                if orientation < 0 {
                    angleSet.append(larmAngle)
                }else if orientation > 0{
                    angleSet.append(larmAngle * -1)
                }else {
                    angleSet.append(-1000)
                }
            } else {
                angleSet.append(-1000)
            }
            
            print("The angle of left arm is  \(larmAngle)");
            self.lelbowLabel.text = String("\(larmAngle)°")
            lArmAngle = larmAngle
        }else{
            angleSet.append(-1000)
        }
        
        if keypoint.contains(7) && keypoint.contains(8){
            let dx1 = xyArray[9][0] - xyArray[8][0];
            let dy1 = xyArray[9][1] - xyArray[8][1];
            let dx2 = xyArray[9][0] - xyArray[10][0];
            let dy2 = xyArray[9][1] - xyArray[10][1];
            let angle1 = atan2(dy1,dx1)*180.0/Double.pi;
            let angle2 = atan2(dy2,dx2)*180.0/Double.pi;
            var rkneeAngle = angle1 - angle2;
            rkneeAngle = round(abs(rkneeAngle))
            if (rkneeAngle > 180) {
                rkneeAngle = 360 - rkneeAngle
            }
            
            if rkneeAngle < 180 {
                let orientation = (xyArray[9][0]-xyArray[8][0])*(xyArray[10][1]-xyArray[8][1]) - (xyArray[9][1]-xyArray[8][1])*(xyArray[10][0]-xyArray[8][0])
                if orientation < 0 {
                    angleSet.append(rkneeAngle)
                }else if orientation > 0{
                    angleSet.append(rkneeAngle * -1)
                }else {
                    angleSet.append(-1000)
                }
            } else {
                angleSet.append(-1000)
            }
            
            print("The angle of right foot is \(rkneeAngle)");
            self.rkneeLabel.text = String("\(rkneeAngle)°")
            rKneeAngle = rkneeAngle
            
        }else{
            angleSet.append(-1000)
        }
        
        if keypoint.contains(11) && keypoint.contains(10){
            let dx1 = xyArray[12][0] - xyArray[11][0];
            let dy1 = xyArray[12][1] - xyArray[11][1];
            let dx2 = xyArray[12][0] - xyArray[13][0];
            let dy2 = xyArray[12][1] - xyArray[13][1];
            let angle1 = atan2(dy1,dx1)*180.0/Double.pi;
            let angle2 = atan2(dy2,dx2)*180.0/Double.pi;
            var lkneeAngle = angle1 - angle2;
            lkneeAngle = round(abs(lkneeAngle))
            if (lkneeAngle > 180) {
                lkneeAngle = 360 - lkneeAngle
            }
            
            if lkneeAngle < 180 {
                let orientation = (xyArray[12][0]-xyArray[11][0])*(xyArray[13][1]-xyArray[11][1]) - (xyArray[12][1]-xyArray[11][1])*(xyArray[13][0]-xyArray[11][0])
                if orientation < 0 {
                    angleSet.append(lkneeAngle)
                }else if orientation > 0{
                    angleSet.append(lkneeAngle * -1)
                }else {
                    angleSet.append(-1000)
                }
            } else {
                angleSet.append(-1000)
            }
            
            print("The angle of left foot is \(lkneeAngle)");
            self.lkneeLabel.text = String("\(lkneeAngle)°")
            lKneeAngle = lkneeAngle
            
        }else{
            angleSet.append(-1000)
        }
        
        if keypoint.contains(6) && keypoint.contains(9){
            //            let cx = (xyArray[6][0] + xyArray[9][0]) / 2;
            //            let cy = (xyArray[6][1] + xyArray[9][1]) / 2;
            var bodyAngle = atan2((xyArray[6][0] - xyArray[1][0]),(xyArray[6][1] - xyArray[1][1]))*180.0/Double.pi;
            
            bodyAngle = round(abs(bodyAngle))
            //            if (angle > 180) {
            //                angle = 360 - angle
            //            }
            print("The angle of body is \(bodyAngle)");
            self.bodyLabel.text = String("\(bodyAngle)°")
            self.bodyAngle = bodyAngle
        }
        
        if keypoint.contains(7) && keypoint.contains(10){
            let dx1 = xyArray[8][0] - xyArray[9][0];
            let dy1 = xyArray[8][1] - xyArray[9][1];
            let dx2 = xyArray[8][0] - xyArray[12][0];
            let dy2 = xyArray[8][1] - xyArray[12][1];
            let angle1 = atan2(dy1,dx1)*180.0/Double.pi;
            let angle2 = atan2(dy2,dx2)*180.0/Double.pi;
            var twoLegAngle = angle1 - angle2;
            twoLegAngle = round(abs(twoLegAngle))
            if (twoLegAngle > 180) {
                twoLegAngle = 360 - twoLegAngle
            }
            print("The angle of two legs is \(twoLegAngle)");
            
            self.twoLegLabel.text = String("\(twoLegAngle)°")
            self.twoLegAngle = twoLegAngle
        }
        
        if (keypoint.contains(0) || keypoint.contains(1)) &&
            (keypoint.contains(2) || keypoint.contains(3)) &&
            (keypoint.contains(4) || keypoint.contains(5)) {
            let dx1 = xyArray[1][0] - xyArray[3][0];
            let dy1 = xyArray[1][1] - xyArray[3][1];
            let dx2 = xyArray[1][0] - xyArray[6][0];
            let dy2 = xyArray[1][1] - xyArray[6][1];
            let angle1 = atan2(dy1,dx1)*180.0/Double.pi;
            let angle2 = atan2(dy2,dx2)*180.0/Double.pi;
            var twoArmAngle = angle1 - angle2;
            twoArmAngle = round(abs(twoArmAngle))
            if (twoArmAngle > 180) {
                twoArmAngle = 360 - twoArmAngle
            }
            print("The angle of two arms is \(twoArmAngle)");
            self.twoArmLabel.text = String("\(twoArmAngle)")
            self.twoArmAngle = twoArmAngle
            //            self.lkneeLabel.text = String("\(twoLegAngle)°")
            //            lKneeAngle = lkneeAngle
        }
        
        if keypoint.contains(12) {
            let dx = xyArray[1][0] - xyArray[0][0];
            let dy = xyArray[1][1] - xyArray[0][1];
            var angle = atan2(dy,dx)*180.0/Double.pi;
            angle = round(abs(angle))
            if (angle > 180) {
                angle = 360 - angle
            }
            print("The angle of neck is \(angle)");
            //            self.lkneeLabel.text = String("\(angle)°")
        }
        
        let renderedImage = openCVWrapper.renderKeyPoint(myImage.frame,
                                                         keypoint: &keypoint,
                                                         keypoint_size: Int32(keypoint.count),
                                                         pos: &pos,
                                                         angleSet: &angleSet)
        
        
        drawLayer.contents = renderedImage.cgImage
        
        myImage.layer.addSublayer(drawLayer)
        
    }
    // MARK: - Help Methods
    
    func measure <T> (_ f: @autoclosure () -> T) -> (result: T, duration: String) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = f()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, "Elapsed time is \(timeElapsed) seconds.      \(Date())")
    }
    
    @IBAction func suggestBtn(sender: UIButton) {
        performSegue(withIdentifier: "showSuggest", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "showSuggest" {
                    let vc = segue.destination as! SuggestionPage
//                    vc.preferredContentSize = CGSize(width: 200, height: 100)
                    vc.rArmAngle = self.rArmAngle
                    vc.lArmAngle = self.lArmAngle
                    vc.rKneeAngle = self.rKneeAngle
                    vc.lKneeAngle = self.lKneeAngle
                    vc.twoArmAngle = self.twoArmAngle
                    vc.twoLegAngle = self.twoLegAngle
                    
                    let controller = vc.popoverPresentationController
                    if controller != nil {
                        controller?.delegate = self
                    }
                }
    }
    
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//       return .none
//    }
//        if segue.identifier == "showSuggestPopup" {
//            let vc = segue.destination
//            vc.preferredContentSize = CGSizeMake(200, 100)
//            let controller = vc.popoverPresentationController
//            if controller != nil {
//                controller?.delegate = self
//            }
//        }
   
    
    
}


