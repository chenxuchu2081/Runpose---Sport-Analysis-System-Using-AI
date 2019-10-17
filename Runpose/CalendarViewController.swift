//
//  CalendarViewController.swift
//  Runpose
//
//  Created by DennisChiu on 16/4/2019.
//  Copyright © 2019年 DennisChiu. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

let imageCache = NSCache<NSString, AnyObject>()
class CalendarViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {

    
    @IBOutlet weak var calendar: JTAppleCalendarView!
    
    let formatter = DateFormatter()
    var generateInDates: InDateCellGeneration = .forFirstMonthOnly    //.forFirstMonthOnly .forAllMonths .off
    var generateOutDates: OutDateCellGeneration = .off    //.tillEndOfRow .tillEndOfGrid .off
    
    var selectDay : String?
    
    
    @IBOutlet weak var AnalysisTableView : UITableView!
    
    let cellId = "cells"
    var uid = ""
    var tableDataList = [String:Array<String>]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalysisTableView.delegate = self
        AnalysisTableView.dataSource = self
        
        if let user = Auth.auth().currentUser {
            uid = user.uid
        }
            
        formatter.dateFormat = "yyyy MM dd"
        selectDay = formatter.string(from: Date())
        calendar.scrollToDate(Date(), animateScroll: false)
        calendar.selectDates([Date()])
        calendar.reloadDates(calendar.selectedDates)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        listImageData()
    }
    
    func listImageData() {
        Database.database().reference().child("users/account/\(uid)/images").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.tableDataList[self.selectDay!] = []
            
            if let dictionary = snapshot.value as? [String: AnyObject] {

               
                
                for (key, value) in dictionary{
                    
                    print(key)
                    self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
                    var aaa = self.formatter.date(from: key)
           
                    self.formatter.dateFormat = "yyyy MM dd"
                    
                    var bbb = self.formatter.string(from: aaa!)
                    
                    print(bbb)
                    print(self.selectDay)
                    if bbb == self.selectDay!{
                        
                        if self.tableDataList.keys.contains(self.selectDay!){
                            
                            self.tableDataList[self.selectDay!]?.append(value as! String)
                        }else{
                            self.tableDataList[self.selectDay!] = [value as! String]
                        }
                    }
                }
                
                
               
                
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    self.AnalysisTableView.reloadData()
                })
            }
            
        }, withCancel: nil)
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2020 12 30")!
        
       
        let parameter = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 1, generateInDates: generateInDates, generateOutDates: generateOutDates,firstDayOfWeek:.monday)
        return parameter
    }
    
    
}

extension CalendarViewController: JTAppleCalendarViewDelegate{
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        
        let cell = cell as! CellView
        
        if cellState.isSelected{
            cell.selectView.isHidden = false
        } else {
            cell.selectView.isHidden = true
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        cell.dateLB.text = cellState.text
        
        if cellState.isSelected{
            cell.selectView.isHidden = false
        } else {
            cell.selectView.isHidden = true
        }
        
        return cell
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let Cell = cell as? CellView else{return}
        formatter.dateFormat = "yyyy MM dd"
        selectDay = formatter.string(from: date)
        
        if cellState.isSelected{
            Cell.selectView.isHidden = false
        } else {
            Cell.selectView.isHidden = true
        }
        
        listImageData()
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let Cell = cell as? CellView else{return}
        
        if cellState.isSelected{
            Cell.selectView.isHidden = false
        } else {
            Cell.selectView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableDataList[selectDay!]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AnalysisTableViewCell
        
        let analysis = tableDataList[selectDay!]![indexPath.row]
        

        
        cell.displayImagecell.loadImageUsingCacheWithUrlString(analysis)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
    
}

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
    
}


