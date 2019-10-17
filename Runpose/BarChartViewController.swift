//
//  BarChartViewController.swift
//  Runpose
//
//  Created by Yiu Lik Ngai on 22/4/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit
import Charts
import HealthKit

//protocol MyViewDelegate {
//    func viewString() -> String;
//}
//
//class MyView : UIView {
//    var myViewDelegate : MyViewDelegate?
//    private var str : String?
//
//    func reloadData() {
//        if myViewDelegate != nil {
//            str = myViewDelegate!.viewString()
//        }
//        self.setNeedsDisplay()
//    }
//
//    override func draw(_ rect: CGRect) {
//        UIColor.white.setFill()
//        UIRectFill(self.bounds)
//        if str != nil {
//            let ns = str! as NSString
////            ns.drawInRect(self.bounds, withAttributes: )
//            ns.draw(in: self.bounds, withAttributes: [NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
//        }
//    }
//}



class BarChartViewController: UIViewController{
    //    func viewString() -> String {
    //        return "blabla"
    //    }
    //    var v : MyView!
    var barChartView : BarChartView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var stepLabel: UILabel!
    var steps = [Int]()
    var date = Date()
    let dateFormatter = DateFormatter()
    let dayFormatter = DateFormatter()
    let healthStore = HKHealthStore()

    @IBOutlet var sumStepLabel: UILabel!
    //    @IBOutlet var minStepLabel: UILabel!
    //    @IBOutlet var maxStepLabel: UILabel!
    @IBOutlet var averageStepLabel: UILabel!
    @IBOutlet var sumDistanceLabel: UILabel!
    @IBOutlet var averageStepSpeedLabel: UILabel!
    @IBOutlet var barChartPlace: UIView!
    @IBOutlet var chartView: UIView!
    
    let statusbarHeight = UIApplication.shared.statusBarFrame.height
    
//    @IBOutlet var button: UIButton!
    var sumStep = 0.0
    var averageStep = 0.0
    var sumDistance = 0.0
    var averageStepSpeed = 0.0
    //    let hkStatistics = HKStatisticsCollectionQuery.self
    override func viewDidLoad() {
        super.viewDidLoad()
//        button.imageEdgeInsets.bottom = 10
//        button.imageEdgeInsets.left = 10
//        button.imageEdgeInsets.top = 10
//        button.imageEdgeInsets.right = 10
//
//        readStep()
        
        
        barChartView = BarChartView()
        dateFormatter.dateFormat = "LLLL yyyy"
        dateLabel.text = dateFormatter.string(from: date)
        print("chartView height : \(chartView.bounds.height)")
        
        print("barchartView height : \(barChartPlace.bounds.height),\(barChartPlace.bounds.origin.x),\(barChartPlace.bounds.origin.y),")
//        barChartView.frame = CGRect(x: barChartPlace.bounds.origin.x, y: barChartPlace.bounds.origin.y, width: barChartPlace.bounds.width, height: barChartView.bounds.height)
//        barChartView.frame = CGRect(x: 0, y: 0, width: barChartPlace.bounds.width, height: barChartView.bounds.height)
        let barWidth: Int = Int(barChartPlace.bounds.width)
        let barHeight: Int = Int(barChartView.bounds.height)
//        barChartView.frame = CGRect(x: 0, y: 0, width: barWidth, height: barHeight)

        print("first barchart x:\(self.barChartView.bounds.origin.x) y:\(self.barChartView.bounds.origin.y) width:\(self.barChartView.bounds.width) height:\(self.barChartView.bounds.height)")
//        self.view.addSubview(barChartView)

        
        //        readDistanceWalkAndRun()
        //        setLabel()
        
        //        v = MyView(frame: self.view.bounds)
        //        self.view.addSubview(v)
        //
        //        v.myViewDelegate = self;
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
//        super.viewDidAppear(animated)
//        barChartView = BarChartView()
//        dateFormatter.dateFormat = "LLLL yyyy"
//        dateLabel.text = dateFormatter.string(from: date)
//        print("chartView height : \(chartView.bounds.height)")
//
//        print("barchartView height : \(barChartPlace.bounds.height),\(barChartPlace.bounds.origin.x),\(barChartPlace.bounds.origin.y),")
        barChartView.frame = CGRect(x: 0, y: 0, width: barChartPlace.bounds.width, height: barChartPlace.bounds.height)
//
//        barChartView.frame = barChartPlace.frame
        barChartPlace.addSubview(barChartView)
        readStep()
//        print("first barchart x:\(self.barChartView.bounds.origin.x) y:\(self.barChartView.bounds.origin.y) width:\(self.barChartView.bounds.width) height:\(self.barChartView.bounds.height)")
//        barChartPlace.addSubview(barChartView)
//        readStep()
    }
    func setLabel() {
        
        //        DispatchQueue.global(qos: .background).async {
        //
        //            // Background Thread
        //
        //            DispatchQueue.main.async {
        //                self.sumStepLabel.text = "\(Int(self.sumStep))"
        //                self.averageStepLabel.text = "\(Int(self.averageStep))"
        //                self.sumDistanceLabel.text = String(format: "%.2dkm"	, self.sumDistance)
        //                self.averageStepSpeedLabel.text = String(format: "%.1dm/step",(self.sumDistance / self.sumStep))
        //            }
        //        }
        
        
    }
    
    
    //
    //    func drawBarChart() {
    //
    //
    //
    //        let startOfMonth = getStartDay()
    //        let endOfMonth = getEndDay(startOfMonth: startOfMonth)
    //        let dayInt = getDayInt(endOfMonth: endOfMonth)
    //
    //                var dataEntries = [BarChartDataEntry]()
    //                for i in 0..<dayInt {
    //                    let entry = BarChartDataEntry(x: (Double(i+1)), y: Double(steps[i]))
    //                    dataEntries.append(entry)
    //
    //                }
    //                let chartDataSet = BarChartDataSet(values: dataEntries, label: "sample")
    //
    //                let chartData = BarChartData(dataSets: [chartDataSet])
    //                barChartView.data = chartData
    //
    //    }
    
    @IBAction func previouMonth(sender: UIButton) {
        steps.removeAll()
        date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        dateFormatter.dateFormat = "LLLL yyyy"
        dateLabel.text = dateFormatter.string(from: date)
        readStep()
        //        readDistanceWalkAndRun()
        //        setLabel()
    }
    
    @IBAction func nextMonth(sender: UIButton) {
        steps.removeAll()
        date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        dateFormatter.dateFormat = "LLLL yyyy"
        dateLabel.text = dateFormatter.string(from: date)
        readStep()
        //        readDistanceWalkAndRun()
        //        setLabel()
    }
    
    func getStartDay() -> Date {
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
        let startOfMonth = Calendar.current.date(from: comp)!
        
        return startOfMonth
        
    }
    
    func getEndDay(startOfMonth: Date) -> Date {
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = Calendar.current.date(byAdding: comps2, to: startOfMonth)
        
        return endOfMonth!
    }
    
    func getDayInt(endOfMonth: Date) -> Int {
        dayFormatter.dateFormat = "dd"
        let dayString = dayFormatter.string(from: endOfMonth)
        let dayInt = Int(dayString)
        
        return dayInt!
    }
    
    
    func readStep(){
        
        /////////////////
        
        let startOfMonth = getStartDay()
        let endOfMonth = getEndDay(startOfMonth: startOfMonth)
        let dayInt = getDayInt(endOfMonth: endOfMonth)
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to get the step count type ***")
        }
        
        var interval = DateComponents()
        interval.day = 1
        
        let calendar = Calendar.current
        //        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: self.date)
        let anchorDate = calendar.date(bySetting: .day, value: 1, of: self.date)
        
        let query = HKStatisticsCollectionQuery.init(quantityType: stepCountType,
                                                     quantitySamplePredicate: nil,
                                                     options: .cumulativeSum,
                                                     anchorDate: anchorDate!,
                                                     intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(error?.localizedDescription) ***")
            }
            var dataEntries = [BarChartDataEntry]()
            
            var thisDay = startOfMonth
            var totalSteps = 0.0
            for i in 1...dayInt {
                var nextDay: Date = calendar.date(byAdding: .day, value: 1, to: thisDay)!
                // Plot the weekly step counts over the past 3 months
                statsCollection.enumerateStatistics(from: thisDay, to: thisDay) { [unowned self] statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        
                        let barEntry = BarChartDataEntry(x: (Double(i)), y: value)
                        dataEntries.append(barEntry)
                        totalSteps += value
                        // Call a custom method to plot each data point.
                        
                    }
                }
                thisDay = nextDay
            }
            
            DispatchQueue.main.async {
                self.sumStep = totalSteps
                self.averageStep = (totalSteps / Double(dayInt))
                self.readDistanceWalkAndRun()
            }
            
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Steps")
            chartDataSet.drawValuesEnabled = false
//            chartDataSet.notifyDataSetChanged()
            let chartData = BarChartData(dataSets: [chartDataSet])
            chartData.barWidth = 0.5
//            chartData.notifyDataChanged()
            self.barChartView.data = chartData
//            self.barChartView.notifyDataSetChanged()
            self.barChartView!.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
            print("after chartView height : \(self.chartView.bounds.height)")
            print("after barchartView height : \(self.barChartPlace.bounds.height)")

            print("barchart x:\(self.barChartView.bounds.origin.x) y:\(self.barChartView.bounds.origin.y) width:\(self.barChartView.bounds.width) height:\(self.barChartView.bounds.height)")
        }
        
        healthStore.execute(query)
        
    }
    
    
    //        query.initialResultsHandler = {
    //            query, results, error in
    //
    ////            let startDate: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
    //
    //            var dataEntries = [BarChartDataEntry]()
    //
    //            var thisDay = startOfMonth
    //            var totalSteps = 0.0
    //            let startDate = calendar.startOfDay(for: self.date)
    //            for i in 1...dayInt {
    //
    //                var nextDay = calendar.date(byAdding: .day, value: 1, to: thisDay)
    //                results?.enumerateStatistics(from: thisDay,
    //                                             to: nextDay!, with: { (result, stop) in
    ////                                                print("Time: \(result.startDate), \(result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)");
    ////                                                self.steps.append(Int(result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0))
    //                                                let barEntry = BarChartDataEntry(x: (Double(i)), y: (result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0))
    //                                                dataEntries.append(barEntry)
    //                                                totalSteps += (result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
    //
    //
    //                })
    //
    //                thisDay = nextDay!
    //            }
    //
    //            DispatchQueue.main.async {
    //                self.sumStepLabel.text = String(Int(totalSteps))
    //                self.averageStepLabel.text = String(Int(totalSteps / Double(dayInt)))
    //            }
    //
    //            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Steps")
    //            chartDataSet.drawValuesEnabled = false
    //            chartDataSet.notifyDataSetChanged()
    //            let chartData = BarChartData(dataSets: [chartDataSet])
    //            chartData.barWidth = 0.5
    //            chartData.notifyDataChanged()
    //            self.barChartView.data = chartData
    //            self.barChartView.notifyDataSetChanged()
    //            self.barChartView!.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
    //
    //
    //        }
    //
    //        healthStore.execute(query)
    //
    //    }
    
    func readDistanceWalkAndRun(){
        let startOfMonth = getStartDay()
        let endOfMonth = getEndDay(startOfMonth: startOfMonth)
        let dayInt = getDayInt(endOfMonth: endOfMonth)
        
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            fatalError("*** Unable to get the step count type ***")
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth, options: .strictStartDate)
        
        let distancequery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            var Count = 0.0
            
            guard let result = result else {
                print("Failed to fetch steps rate")
                return
            }
            if let sum = result.sumQuantity() {
                Count = sum.doubleValue(for: HKUnit.meter())
            }
            print(Count)
            
            DispatchQueue.main.async {
                
                self.sumDistance = (Count/1000)
                self.sumStepLabel.text = "\(Int(self.sumStep))"
                self.averageStepLabel.text = "\(Int(self.averageStep)) steps/day"
                self.sumDistanceLabel.text = String(format: "%.2fkm", self.sumDistance)
                
                if Count == 0 {
                    self.averageStepSpeedLabel.text = "0m/step"
                } else if Count > 0 {
                    self.averageStepSpeedLabel.text = String(format: "%.1fm/step",(Count / self.sumStep))
                }

            }
            
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
        }
        healthStore.execute(distancequery)
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
