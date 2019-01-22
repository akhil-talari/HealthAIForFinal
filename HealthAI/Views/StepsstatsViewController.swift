//
//  StepsstatsViewController.swift
//  HealthAI
//
//  Created by Team9 on 12/3/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit
import CoreMotion
import SwiftCharts

import Charts



class StepsstatsViewController: UIViewController {
    var target1 : Int = 0
    class details {
        let stepsOutput: [Int]
        let daysstring: [String]
        
        init(stepoup: [Int], dayoup: [String]) {
            stepsOutput = stepoup
            daysstring = dayoup
        }
        
    }
    
    @IBAction func saveChart(_ sender: Any) {
        let graphImage = barChartView.getChartImage(transparent: false)
        UIImageWriteToSavedPhotosAlbum(graphImage!, nil, nil, nil)
    }
    
    @IBOutlet weak var barChartView: BarChartView!
    var chartView: BarsChart!
    
    let pedometer = CMPedometer()
    var days:[String] = []
    var stepsTaken:[Int] = []
    
    
    var months: [String]!
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    
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
    
    func displaychart() {
        //                let chartConfig = BarsChartConfig(
        //                    valsAxisConfig: ChartAxisConfig(from: 0, to: 8, by: 2)
        //                )
        //
        //                let frame = CGRect(x: 0, y: 70, width: 300, height: 500)
        //
        //        print(ddd.count)
        //
        //                let chart = BarsChart(
        //                    frame: frame,
        //                    chartConfig: chartConfig,
        //                    xTitle: "X axis",
        //                    yTitle: "Y axis",
        //                    bars: [
        //                        (self.days[1], Double(self.stepsTaken[1])),
        //                        (self.days[1], 4.5),
        //                        (self.days[2], 3),
        //                        (self.days[3], 5.4),
        //                        (self.days[4], 6.8),
        //                        (self.days[5], 0.5)
        //                    ],
        //                    color: UIColor.red,
        //                    barWidth: 20
        //                )
        
        //                self.view.addSubview(chart.view)
        //                self.chartView = chart
    }
    
    func setChart(dataEntryX forX: [String], dataEntryY forY:[Double]) {
        //barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<forX.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]), data: months as AnyObject?)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Steps walked")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartDataSet.colors = ChartColorTemplates.colorful()
        
        
        barChartView.data = chartData
        let xAxisValue = barChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        barChartView.xAxis.labelPosition = .bottom
        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        let ll = ChartLimitLine(limit: Double(target1), label: "Target")
        barChartView.rightAxis.addLimitLine(ll)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let record = getDataForLast7Days()
        axisFormatDelegate = self as! IAxisValueFormatter
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(days[0],days[1],days[2],days[3],days[4],days[6],days[7])
        months = [days[0],days[1],days[2],days[3],days[4],days[6],days[7]]
        
        let unitsSold = [Double(stepsTaken[0]),Double(stepsTaken[1]),Double(stepsTaken[2]),Double(stepsTaken[3]),Double(stepsTaken[4]),Double(stepsTaken[6]),Double(stepsTaken[7])]
        
        //        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        //        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        setChart(dataEntryX: months, dataEntryY: unitsSold)
        
        
        
        //
        //        setChart(dataPoints: months, values: unitsSold)
        
        //                let chartConfig = BarsChartConfig(
        //                    valsAxisConfig: ChartAxisConfig(from: 0, to: 5000, by:1000)
        //                )
        //
        //                let frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        //
        //
        //                let chart = BarsChart(
        //                    frame: frame,
        //                    chartConfig: chartConfig,
        //                    xTitle: "X axis",
        //                    yTitle: "Y axis",
        //                    bars: [
        //                        (days[0], Double(stepsTaken[0])),
        //                        (days[1], Double(stepsTaken[1])),
        //                         (days[2], Double(stepsTaken[2])),
        //                          (days[3], Double(stepsTaken[3])),
        //                          (days[4], Double(stepsTaken[4])),
        //                          (days[5], Double(stepsTaken[5])),
        //                          (days[6], Double(stepsTaken[6]))
        //                    ],
        //                    color: UIColor.red,
        //                    barWidth: 20
        //                )
        //
        //                self.view.addSubview(chart.view)
        //                self.chartView = chart
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

extension StepsstatsViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value)]
    }
}

