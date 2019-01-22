//
//  GraphViewController.swift
//  HealthAI
//
//  Created by Naresh Kumar on 31/10/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit
import Charts

class GraphViewController: UIViewController {
    
    @IBOutlet weak var remainingCal: UILabel!
    @IBOutlet weak var currentCal: UILabel!
    @IBOutlet weak var goalCal: UILabel!

   
    @IBOutlet weak var piechart: PieChartView!
    
    var goalValue:Int = 0
    var currentValue:Int = 0
    var remainingValue:Int = 0
    
    
    
    var calorieScore  = [PieChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goalCal.text = "\(goalValue)"
        
        currentCal.text = "\(currentValue)"
        remainingValue = goalValue - currentValue
        remainingCal.text = "\(remainingValue)"
        
        var currentDayCal = PieChartDataEntry(value: Double(exactly: currentValue)!, label: "Current")
        var remainingDayCal = PieChartDataEntry(value: Double(exactly: remainingValue)!, label: "Remaining")
        
        
        
        calorieScore = [currentDayCal, remainingDayCal]
        
        updateChart()
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func updateChart(){
        piechart.chartDescription?.enabled = false
        piechart.drawHoleEnabled = false
        piechart.rotationAngle = 0
        piechart.rotationEnabled = false
        piechart.isUserInteractionEnabled = false
        
        let dataset = PieChartDataSet(values: calorieScore, label: "")
        print("CalorieScore  ", calorieScore)
        
        dataset.colors = [UIColor.red, UIColor.blue]
        dataset.drawValuesEnabled = false
        piechart.data = PieChartData(dataSet: dataset)
    }
    
}

