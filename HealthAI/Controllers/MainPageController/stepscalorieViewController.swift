//
//  stepscalorieViewController.swift
//  HealthAI
//
//  Created by Team9 on 12/5/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit
import Charts
import CoreMotion

class stepscalorieViewController: UIViewController {
    class details {
        let stepsOutput: [Int]
        let daysstring: [String]
        
        init(stepoup: [Int], dayoup: [String]) {
            stepsOutput = stepoup
            daysstring = dayoup
        }
        
    }
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    //var piechartView: PieChart!
    
    let pedometer = CMPedometer()
    var days:[String] = []
    var stepsTaken:[Int] = []
    
    
    var months: [String]!
    
    func getDataForLast7Days() ->details {
        var ddd = [Int]()
        var sttteps = [String]()
        
        if(CMPedometer.isStepCountingAvailable()){
            let serialQueue : DispatchQueue  = DispatchQueue(label: "com.example.MyQueue", attributes: .concurrent)
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            serialQueue.sync(execute: { () -> Void in
                let today = NSDate()
                
                for day in 3...10{
                    let from = NSDate(timeIntervalSinceNow: Double(-7+day) )
                    let hour = Calendar.current.component(.hour, from: from as Date)
                    let min = Calendar.current.component(.minute, from: from as Date)
                    let sec = Calendar.current.component(.second, from: from as Date)
                    let timeToSub = (hour * 60 + min) * 60 + sec
                    let fromDate = NSDate(timeIntervalSinceNow: (Double(-10+day) * (86400 ) ) - Double(timeToSub))
                    let toDate = NSDate(timeIntervalSinceNow: (Double(-10+day+1) * (86400) ) - Double(timeToSub))
                    let dtStr = formatter.string(from: (toDate as Date))
                    
                    self.pedometer.queryPedometerData(from: fromDate as Date , to: toDate as Date) { (data : CMPedometerData!, error) -> Void in
                        //print("From Date: \(fromDate)","\n\n")
                        if(error == nil){
                            
                            ddd.append(Int(data.numberOfSteps))
                            sttteps.append(dtStr)
                            //                            print(data,"\n\n")
                            print("\(dtStr) : \(data.numberOfSteps)")
                            self.days.append(dtStr)
                            self.stepsTaken.append(Int(data.numberOfSteps))
                            
                            print("Number of Steps in last " , day-3
                                ,  "Days:", self.stepsTaken.reduce(0,+))
                            
                        }
                        
                    }
                    
                    
                }
                //
            })
        }
        return details(stepoup: ddd, dayoup: sttteps)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let record = getDataForLast7Days()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        var days1:[String] = []
        var stepsTaken1:[Double] = []
        
        for i in 0..<stepsTaken.count{
            if(stepsTaken[i] != 0){
                days1.append(days[i])
                stepsTaken1.append(Double(stepsTaken[i]/20))
            }
        }
        
        let months = days1
        
        let unitsSold = stepsTaken1
        
        setChart(days: months, gross: unitsSold)
    }
    
    func setChart(days: [String], gross: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<days.count {
            let dataEntry = PieChartDataEntry(value : gross[i], label : days[i])
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Calories burned")
        let pieChartData = PieChartData( dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        
        var colors: [UIColor] = []
        
        for i in 0..<days.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
        
    }
    
}
