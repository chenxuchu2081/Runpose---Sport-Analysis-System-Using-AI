//

import UIKit
import CoreML
import AVKit
import Vision
import AVFoundation
import Charts
//import ImageIO
//import MobileCoreServices
//import Foundation
class RealtimeScanPage: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - UI Properties
    
    @IBOutlet weak var rArm: UILabel!
    @IBOutlet weak var lArm: UILabel!
    
    @IBOutlet weak var rKnee: UILabel!
    @IBOutlet weak var lKnee: UILabel!
    
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var preview : UIImageView!
    
    @IBOutlet weak var myImage: UIImageView!
    
    var rArmAngleArray = [Double]()
    var lArmAngleArray = [Double]()
    var rKneeAngleArray = [Double]()
    var lKneeAngleArray = [Double]()
    var twoArmAngleArray = [Double]()
    var twoLegAngleArray = [Double]()
    var bodyAngleArray = [Double]()
    
    var lhipflexArray = [Double]()
    var rhipflexArray = [Double]()
    var lshankArray = [Double]()
    var rshankArray = [Double]()
    //    var gif = [UIImage]()
    
    @IBOutlet var suggestBtn: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var context = CIContext(options: nil)
    
    // MARK: - CoreML Properties
    //    let model = MobileOpenPose()
    //    let ImageWidth = 368
    //    let ImageHeight = 368
    
    let model = MobileOpenPose200()
    let ImageWidth = 200
    let ImageHeight = 200
    
    let semaphore = DispatchSemaphore(value: 1)
    
    var hipLineChart: LineChartView!
    var kneeLineChart: LineChartView!
    // MARK: - Lifecycle Methods
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myImage.frame =  CGRect(x: 30, y: 0, width: self.view.bounds.width - 60, height: self.view.bounds.width - 60)
        preview.frame =  CGRect(x: 30, y: 0, width: self.view.bounds.width - 60, height: self.view.bounds.width - 60)
//        lArm.frame = CGRect(x: 30, y: lArm.bounds.origin.y, width: 58, height: 32)
//        rArm.frame = CGRect(x: self.view.bounds.width - 88, y: rArm.bounds.origin.y, width: 58, height: 32)
        rKnee.frame = CGRect(x: 30, y: self.view.bounds.width - 92, width: 58, height: 32)
        lKnee.frame = CGRect(x: self.view.bounds.width - 88, y: self.view.bounds.width - 92, width: 58, height: 32)
//        myImage.frame =  CGRect(x: 30, y: 0, width: 200, height: 200)
//        preview.frame =  CGRect(x: 30, y: 0, width: 200, height: 200)
//        preview.frame =  CGRect(x: 30, y: self.view.bounds.width - 40, width: self.view.bounds.width - 60, height: self.view.bounds.width - 60)
//
        
        ///// Line Chart /////
        hipLineChart = LineChartView()
        kneeLineChart = LineChartView()
        
        hipLineChart.frame = CGRect(x:10, y:self.view.bounds.width - 55, width: self.view.bounds.width - 20,
                                    height: (self.view.bounds.height - self.view.bounds.width - 64) / 2)
        kneeLineChart.frame = CGRect(x:10, y:self.view.bounds.width - 50 + hipLineChart.bounds.height, width: self.view.bounds.width - 20,
                                      height: (self.view.bounds.height - self.view.bounds.width - 64) / 2)
        self.view.addSubview(hipLineChart)
        self.view.addSubview(kneeLineChart)
        //
        //
        //        for i in 0..<10 {
        //            let y = arc4random()%100
        //            let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
        //            dataEntries.append(entry)
        //        }
        //        let chartDataSet = LineChartDataSet(values: dataEntries, label: "图例1")
        //        chartDataSet.colors = [.orange]
        //        chartDataSet.lineWidth = 2
        //        let chartData = LineChartData(dataSets: [chartDataSet])
        //        hipLineChart.data = chartData
        //////////////////////
        
        captureSession.sessionPreset = .vga640x480

        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {return}
        captureDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(30))
        //        captureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, Int32(10))
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else{return}
        captureSession.addInput(input)
        captureSession.startRunning()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        view.layer.addSublayer(previewLayer)
        //        previewLayer.frame = myView.frame
        previewLayer.videoGravity = .resizeAspectFill
        let dataOutput = AVCaptureVideoDataOutput()
        //        dataOutput.alwaysDiscardsLateVideoFrames = false
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String) : (NSNumber(value: kCVPixelFormatType_32BGRA) as! UInt32)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        captureSession.addOutput(dataOutput)
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let apixeBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return}
        
        
        let ciImage = CIImage(cvPixelBuffer: apixeBuffer)
        
        let scale = CGFloat(ImageHeight) / CGFloat(ciImage.extent.height)
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let xDiff = (scaledImage.extent.width - CGFloat(ImageWidth)) / 2
        let yDiff = (scaledImage.extent.height - CGFloat(ImageHeight)) / 2
        let croppedImage = scaledImage.cropped(to: CGRect(x: xDiff, y: yDiff, width: CGFloat(ImageWidth), height: CGFloat(ImageHeight)))
        let concat = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2)).concatenating(CGAffineTransform(translationX: 0, y: croppedImage.extent.height))
        let rotatedImage = croppedImage.transformed(by: concat)
        //let croppedImage = rotatedImage.cropped(to: CGRect(x: 0, y: -160, width: 640, height: 480))
        //let factor = CGFloat(ImageHeight) / CGFloat(rotatedImage.extent.height)
        //print("extent: \(croppedImage.extent)")
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(nil, ImageWidth, ImageHeight,
                                         kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        if status != kCVReturnSuccess {
            print("Error: could not create resized pixel buffer", status)
            return
        }
        context.render(rotatedImage, to: pixelBuffer!)
        guard let thePixelBuffer = pixelBuffer else { return }
        DispatchQueue.global().async {
            self.semaphore.wait()
            if (self.isWriting == false) {
                if let buff = UIImage.init(pixelBuffer: thePixelBuffer){
                    DispatchQueue.main.async {
                        self.preview.image = buff
                    }
                }
                self.isWriting = true
                self.semaphore.signal()
                self.runCoreML(thePixelBuffer)
            } else {
                self.semaphore.signal()
            }
        }
        
        
    }
    var isWriting = false
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CoreML Methods
    
    func runCoreML(_ buffer : CVPixelBuffer){
        if let prediction = try? model.prediction(image: buffer) {
            
            //                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            //                print("coreml elapsed for \(timeElapsed) seconds")
            
            let predictionOutput = prediction.net_output
            let length = predictionOutput.count
            //print(predictionOutput)
            
            let doublePointer =  predictionOutput.dataPointer.bindMemory(to: Double.self, capacity: length)
            let doubleBuffer = UnsafeBufferPointer(start: doublePointer, count: length)
            let mm = Array(doubleBuffer)
            
            DispatchQueue.main.async {
                // Delete Beizer paths of previous image
                self.myImage.layer.sublayers = []
                
                // Draw new lines
                self.drawLines(mm)
                
                self.semaphore.wait()
                self.isWriting = false
                self.semaphore.signal()
            }
        }
    }
    
    
    func runCoreML(_ image: UIImage) {
        //self.preview.image = image
        //return
        
        if let pixelBuffer = image.pixelBuffer(width: ImageWidth, height: ImageHeight) {
            
            //            let startTime = CFAbsoluteTimeGetCurrent()
            if let prediction = try? model.prediction(image: pixelBuffer) {
                
                //                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                //                print("coreml elapsed for \(timeElapsed) seconds")
                
                // Display new image
                //                myImage.image = UIImage(pixelBuffer: pixelBuffer)
                
                let predictionOutput = prediction.net_output
                let length = predictionOutput.count
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
            rArmAngleArray.append(rarmAngle)
            
            rArm.text = "\(rarmAngle)°"
        }else{
            angleSet.append(-1000)
            rArm.text = ""
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
            lArmAngleArray.append(larmAngle)
            lArm.text = "\(larmAngle)°"
        }else{
            angleSet.append(-1000)
            lArm.text = ""
        }
        
        if keypoint.contains(7) && keypoint.contains(8){
            let dx1 = xyArray[9][0] - xyArray[8][0];
            let dy1 = xyArray[9][1] - xyArray[8][1];
            let dx2 = xyArray[9][0] - xyArray[10][0];
            let dy2 = xyArray[9][1] - xyArray[10][1];
            
            ///// Hip Flex /////
            
            /// Right ///
            var rhipflexAngle = atan2(dy1,dx1)*180.0/Double.pi;
            print("first rhipflex = \(rhipflexAngle)")

            if rhipflexAngle < 0 {
                rhipflexAngle = round(360 + rhipflexAngle)
            }
            if rhipflexAngle <= 90 {
                rhipflexAngle = round(180 - 90 - rhipflexAngle)
            } else if rhipflexAngle > 90 {
                rhipflexAngle = round(rhipflexAngle - 90)
            }
            print("rhipflex = \(rhipflexAngle)")
            rhipflexArray.append(rhipflexAngle)
            ////////////////////
            
            ///// Shank /////
            var shankAngle = atan2(dy2,dx2)*180.0/Double.pi;
            if shankAngle <= 0 {
                shankAngle = round(90 + shankAngle)
            } else if shankAngle > 0 {
                shankAngle = round(360 - 90 - shankAngle)
            }
            
            print("rshank = \(shankAngle)")
            rshankArray.append(shankAngle)
            /////////////////
            
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
                
                lKnee.text = "\(rkneeAngle)°"
            } else {
                angleSet.append(-1000)
                lKnee.text = ""
            }
            
            print("The angle of right foot is \(rkneeAngle)");
            rKneeAngleArray.append(rkneeAngle)
        }else{
            angleSet.append(-1000)
        }
        
        if keypoint.contains(11) && keypoint.contains(10){
            let dx1 = xyArray[12][0] - xyArray[11][0];
            let dy1 = xyArray[12][1] - xyArray[11][1];
            let dx2 = xyArray[12][0] - xyArray[13][0];
            let dy2 = xyArray[12][1] - xyArray[13][1];
            
            ///// Hip flex /////
            /// Left ///
            var lhipflexAngle = atan2(dy1,dx1)*180.0/Double.pi;
            print("first lhipflex = \(lhipflexAngle)")
            
            if lhipflexAngle < 0 {
                lhipflexAngle = round(360 + lhipflexAngle)
            }
            
            if lhipflexAngle <= 90 {
                lhipflexAngle = round((180 - 90 - lhipflexAngle))
            } else if lhipflexAngle > 90 {
                lhipflexAngle = round(lhipflexAngle - 90)
            }
            
            print("lhipflex = \(lhipflexAngle)")
            lhipflexArray.append(lhipflexAngle)
            ////////////////////
            
            ///// Shank /////
            var shankAngle = atan2(dy2,dx2)*180.0/Double.pi;
            if shankAngle <= 0 {
                shankAngle = round(90 + shankAngle)
            } else if shankAngle > 0 {
                shankAngle = round(360 - 90 - shankAngle)
            }
            
            print("lshank = \(shankAngle)")
            lshankArray.append(shankAngle)
            /////////////////
            
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
            lKneeAngleArray.append(lkneeAngle)
            rKnee.text = "\(lkneeAngle)°"
        }else{
            angleSet.append(-1000)
            rKnee.text = ""
        }
        
        if keypoint.contains(6) {
            //            let cx = (xyArray[6][0] + xyArray[9][0]) / 2;
            //            let cy = (xyArray[6][1] + xyArray[9][1]) / 2;
            var bodyAngle = atan2((xyArray[8][1] - xyArray[1][1]),(xyArray[8][0] - xyArray[1][0]))*180.0/Double.pi;
            
            bodyAngle = round(abs(bodyAngle))
            //            if (angle > 180) {
            //                angle = 360 - angle
            //            }
            print("The angle of body is \(bodyAngle)");
            //            self.bodyLabel.text = String("\(bodyAngle)°")
            //            self.bodyAngle = bodyAngle
            bodyAngleArray.append(bodyAngle)
        } else if keypoint.contains(9) {
            var bodyAngle = atan2((xyArray[11][1] - xyArray[1][1]),(xyArray[11][0] - xyArray[1][0]))*180.0/Double.pi;
            
            bodyAngle = round(abs(bodyAngle))
            print("The angle of body is \(bodyAngle)");
            bodyAngleArray.append(bodyAngle)
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
            //            self.lkneeLabel.text = String("\(twoLegAngle)°")
            //            self.twoLegAngle = twoLegAngle
            twoLegAngleArray.append(twoLegAngle)
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
            //            self.twoArmAngle = twoArmAngle
            //            self.lkneeLabel.text = String("\(twoLegAngle)°")
            //            lKneeAngle = lkneeAngle
            twoArmAngleArray.append(twoArmAngle)
        }
        
        
        
        
        
        let renderedImage = openCVWrapper.renderKeyPoint(myImage.frame,
                                                         keypoint: &keypoint,
                                                         keypoint_size: Int32(keypoint.count),
                                                         pos: &pos,
                                                         angleSet: &angleSet)
        
        
        drawLayer.contents = renderedImage.cgImage
        myImage.layer.addSublayer(drawLayer)
        
        if lhipflexArray.count > rhipflexArray.count {
            rhipflexArray.append(0)
        } else if rhipflexArray.count > lhipflexArray.count {
            lhipflexArray.append(0)
        }
        
        if lKneeAngleArray.count > rKneeAngleArray.count {
            rKneeAngleArray.append(0)
        } else if rKneeAngleArray.count > lKneeAngleArray.count {
            lKneeAngleArray.append(0)
        }
        
        /////////////////////////// Hip Chart ///////////////////////////
        
        var rhipdataEntries = [ChartDataEntry]()
        var lhipdataEntries = [ChartDataEntry]()
        /// Line Chart ///
        var j = 0
        ////////// Left Hip //////////
        //        if lhipflexArray.count > 5 {
        //            for i in (lhipflexArray.count - 5)..<lhipflexArray.count {
        //                j += 1
        //                let entry = ChartDataEntry.init(x: Double(j) , y: lhipflexArray[i])
        //
        //                lhipdataEntries.append(entry)
        //            }
        //        } else
        if !lhipflexArray.isEmpty {
            for i in 0..<lhipflexArray.count {
                let entry = ChartDataEntry.init(x: Double(i+1) , y: lhipflexArray[i])
                
                lhipdataEntries.append(entry)
            }
        }
        let lchartDataSet = LineChartDataSet(values: lhipdataEntries, label: "Left hip")
        
        lchartDataSet.colors = [.blue]
        lchartDataSet.lineWidth = 2
        lchartDataSet.drawCirclesEnabled = false
        lchartDataSet.drawValuesEnabled = false
        //        lchartDataSet.highlightEnabled = false
        lchartDataSet.mode = .cubicBezier
        
        ///////////////////////////////
        
        ////////// Right Hip //////////
        //        j = 0
        //        if rhipflexArray.count > 5 {
        //            for i in (rhipflexArray.count - 5)..<rhipflexArray.count {
        //                j += 1
        //                let entry = ChartDataEntry.init(x: Double(j) , y: rhipflexArray[i])
        //
        //                lhipdataEntries.append(entry)
        //            }
        //        } else
        if !rhipflexArray.isEmpty {
            for i in 0..<rhipflexArray.count {
                let entry = ChartDataEntry.init(x: Double(i+1) , y: rhipflexArray[i])
                rhipdataEntries.append(entry)
            }
        }
        let rchartDataSet = LineChartDataSet(values: rhipdataEntries, label: "Right hip")
        
        rchartDataSet.colors = [.orange]
        rchartDataSet.lineWidth = 2
        rchartDataSet.drawCirclesEnabled = false
        rchartDataSet.drawValuesEnabled = false
        //        rchartDataSet.highlightEnabled = false
        rchartDataSet.mode = .cubicBezier
        
        ///////////////////////////////
        
        let chartData = LineChartData(dataSets: [lchartDataSet,rchartDataSet])
        
        hipLineChart.xAxis.drawGridLinesEnabled = false
        //        hipLineChart.xAxis.axisMinimum = 0
        //        hipLineChart.xAxis.axisMaximum = 10
        hipLineChart.data = chartData
        
        hipLineChart.data?.notifyDataChanged()
        hipLineChart.notifyDataSetChanged()
        //        self.hipLineChart!.animate(xAxisDuration: 0.1, yAxisDuration: 0.1)
        /////////////////////////////////////////////////////////////////////////
        
        
        
        
        /////////////////////////// Shank Chart ///////////////////////////
        var rkneedataEntries = [ChartDataEntry]()
        var lkneedataEntries = [ChartDataEntry]()
        
        /// Line Chart ///
        
        ////////// Left knee //////////
        
        //        if lhipflexArray.count > 5 {
        //            for i in (lhipflexArray.count - 5)..<lhipflexArray.count {
        //                j += 1
        //                let entry = ChartDataEntry.init(x: Double(j) , y: lhipflexArray[i])
        //
        //                lhipdataEntries.append(entry)
        //            }
        //        } else
        if !lKneeAngleArray.isEmpty {
            for i in 0..<lKneeAngleArray.count {
                let entry = ChartDataEntry.init(x: Double(i+1) , y: 180 - lKneeAngleArray[i])
                
                lkneedataEntries.append(entry)
            }
        }
        let lkneeDataSet = LineChartDataSet(values: lkneedataEntries, label: "Left knee")
        
        lkneeDataSet.colors = [.blue]
        lkneeDataSet.lineWidth = 2
        lkneeDataSet.drawCirclesEnabled = false
        lkneeDataSet.drawValuesEnabled = false
        //        lchartDataSet.highlightEnabled = false
        lkneeDataSet.mode = .cubicBezier
        
        ///////////////////////////////
        
        ////////// Right knee //////////
        
        //        j = 0
        //        if rhipflexArray.count > 5 {
        //            for i in (rhipflexArray.count - 5)..<rhipflexArray.count {
        //                j += 1
        //                let entry = ChartDataEntry.init(x: Double(j) , y: rhipflexArray[i])
        //
        //                lhipdataEntries.append(entry)
        //            }
        //        } else
        if !rKneeAngleArray.isEmpty {
            for i in 0..<rKneeAngleArray.count {
                let entry = ChartDataEntry.init(x: Double(i+1) , y: 180 - rKneeAngleArray[i])
                rkneedataEntries.append(entry)
            }
        }
        let rkneeDataSet = LineChartDataSet(values: rkneedataEntries, label: "Right knee")
        
        rkneeDataSet.colors = [.orange]
        rkneeDataSet.lineWidth = 2
        rkneeDataSet.drawCirclesEnabled = false
        rkneeDataSet.drawValuesEnabled = false
        //        rchartDataSet.highlightEnabled = false
        rkneeDataSet.mode = .cubicBezier
        
        ///////////////////////////////
        
        let kneeChartData = LineChartData(dataSets: [lkneeDataSet,rkneeDataSet])
        
        kneeLineChart.xAxis.drawGridLinesEnabled = false
        //        hipLineChart.xAxis.axisMinimum = 0
        //        hipLineChart.xAxis.axisMaximum = 10
        kneeLineChart.data = kneeChartData
        
        kneeLineChart.data?.notifyDataChanged()
        kneeLineChart.notifyDataSetChanged()
        ///////////////////////////////////////////////////////////////////
        
        
        
        
        
        //// test ////
        //        if myImage.image != nil {
        //            gif.append(myImage.image!)
        //        }
        //////////////
    }
    // MARK: - Help Methods
    
    func measure <T> (_ f: @autoclosure () -> T) -> (result: T, duration: String) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = f()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, "Elapsed time is \(timeElapsed) seconds.      \(Date())")
    }
    
    @IBAction func suggestBtn(sender: UIButton) {
        
        captureSession.stopRunning()
        performSegue(withIdentifier: "showRealtimeSuggestion", sender: nil)
        //        UIImage.animatedGif(from: sinf)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRealtimeSuggestion" {
            let vc = segue.destination as! RealtimeSuggestPage
            //                    vc.preferredContentSize = CGSize(width: 200, height: 100)
            vc.rArmAngleArray = self.rArmAngleArray
            vc.lArmAngleArray = self.lArmAngleArray
            vc.rKneeAngleArray = self.rKneeAngleArray
            vc.lKneeAngleArray = self.lKneeAngleArray
            vc.twoArmAngleArray = self.twoArmAngleArray
            vc.twoLegAngleArray = self.twoLegAngleArray
            vc.bodyAngleArray = self.bodyAngleArray
            
            
        }
    }
}

