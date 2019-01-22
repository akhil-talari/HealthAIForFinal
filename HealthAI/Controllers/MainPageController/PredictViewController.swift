//
//  PredictViewController.swift
//
//
//  Created by Naresh Kumar on 05/12/18.
//

import UIKit
import RealmSwift
import Charts

class PredictViewController: UIViewController,ChartViewDelegate {
    
    var ageArray = [Double]()
    var glucoseArray = [Double]()
    var heightArray = [Double]()
    var weightArray = [Double]()
    var bloodPressureArray = [Double]()
    
    
    @IBOutlet weak var addData: UIButton!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var tableView: UITableView!
    
    var healthRecords: Results<HealthRecord>!
    var notificationToken : NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let realm = RealmService.shared.realm
        healthRecords = realm.objects(HealthRecord.self)
        
        notificationToken = realm.observe{ (notification, realm) in
            self.tableView.reloadData()
            
            //            let xyValues = self.futurePrediction()
        }
        
        RealmService.shared.observeRealmErrors(in: self) { (error) in
            print(error ?? "no error detected")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        futurePrediction()
        setChartData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationToken!.invalidate()
        RealmService.shared.stopObservingErrors(in: self)
    }
    
    @IBAction func onAddTapped(_ sender: UIButton) {
        AlertService.addAlert(in:self){(age, glucose,height,weight,bloodPressure) in
            
            let newHealthRecord = HealthRecord(age: age!, glucose: glucose!, height: height!, weight: weight!, bloodPressure: bloodPressure!)
            
            RealmService.shared.create(newHealthRecord)
            print(newHealthRecord)
        }
    }
    
    
    func futurePrediction(){
        
        if ageArray.count == 0
        {
            onAddTapped(addData)
        }
        else{
            print("Inside Age Array")
            print(ageArray)
            print(ageArray[ageArray.count-1])
            
            var BMIArray = [Double]()
            
            for i in 0...(heightArray.count-1){
                var BMIvalues = weightArray[i]/((heightArray[i]/100) * (heightArray[i]/100))
                BMIArray.insert(BMIvalues, at: i)
                print(i, BMIvalues)
            }
            print(BMIArray)
            
            for i in 0...2{
                var BMITotal = BMIArray.reduce(0, +)
                BMITotal = BMITotal - BMIArray[BMIArray.count - 1]
                var avgBMIIncrease = (BMIArray[BMIArray.count - 1] - (BMITotal/Double(BMIArray.count - 1)))/Double(BMIArray.count)
                
                print("AverageBMIIncrease")
                print(avgBMIIncrease)
                
                var bloodPressureTotal:Double = bloodPressureArray.reduce(0, +)
                bloodPressureTotal = bloodPressureTotal - bloodPressureArray[bloodPressureArray.count - 1]
                var avgBPIncrease = (bloodPressureArray[bloodPressureArray.count - 1] - (bloodPressureTotal/Double(bloodPressureArray.count - 1)))/Double(bloodPressureArray.count)
                
                print("AverageBPIncrease")
                print(avgBPIncrease)
                
                //        let BMIDifference = BMITotal/Double(BMIArray.count) - BMIArray[BMIArray.count-1]
                //            print("BMIDifference")
                //            print(BMIDifference)
                //
                //        let bloodPressureDifference = bloodPressureTotal/Double(bloodPressureArray.count) - bloodPressureArray[bloodPressureArray.count - 1]
                //            print("bloodPressureDifference")
                //            print(bloodPressureDifference)
                
                let nextBloodPressure = (Double(bloodPressureArray[bloodPressureArray.count - 1]) + Double(avgBPIncrease))
                print("nextBloodPressure")
                print(nextBloodPressure)
                bloodPressureArray.append(nextBloodPressure)
                let eqnBp = 0.04212 * nextBloodPressure
                
                let nextBMI = (Double(BMIArray[BMIArray.count-1]) + Double(avgBMIIncrease))
                print("nextBMI")
                print(nextBMI)
                BMIArray.append(nextBMI)
                let eqnBMI = 0.82873 * nextBMI
                
                let nextAge = (Double(ageArray[ageArray.count-1]) + Double(1))
                print("nextAge")
                print(nextAge)
                ageArray.append(nextAge)
                let eqnAge = 0.66087 * nextAge
                
                let predictiveGlucoseValue = 69.66151 + eqnBp + eqnBMI + eqnAge
                glucoseArray.append(predictiveGlucoseValue)
                
                print(avgBPIncrease, avgBMIIncrease, nextAge)
                
                print("Predicted Glucose Value")
                print(predictiveGlucoseValue)
                
                //        print(BMIArray)
                //        print(graphValuesArray)
            }
            print(ageArray)
            print(glucoseArray)
        }
    }
    
    func setChartData(){
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< ageArray.count {
            yVals1.append(ChartDataEntry(x:Double(i) , y:glucoseArray[i]))
        }
        
        let set1: LineChartDataSet = LineChartDataSet(values: yVals1, label: "")
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor.red.withAlphaComponent(0.5))
        set1.setCircleColor(UIColor.red)
        set1.circleRadius = 3.0
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.red
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = false
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        
        var stringAge = [String]()
        
        if ageArray.count - 1 > 1 {
            for i in 0...ageArray.count - 1 {
                stringAge.append(String(ageArray[i]))
            }
        }
        
        let data : LineChartData = LineChartData(dataSets: dataSets)
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: stringAge)
        
        
        self.lineChart.data = data
        
        lineChart.xAxis.granularity = 1 //  to show intervals
        lineChart.xAxis.wordWrapEnabled = true
        
        lineChart.xAxis.labelFont = UIFont.boldSystemFont(ofSize: 8.0)
        
        lineChart.xAxis.labelPosition = .bottom // lebel position on graph
        //
        lineChart.legend.form = .line // indexing shape
        lineChart.xAxis.drawGridLinesEnabled = false // show gird on graph
        lineChart.rightAxis.drawLabelsEnabled = false// to show right side value on graph
        lineChart.data?.setDrawValues(false) //
        lineChart.chartDescription?.text = ""
        lineChart.doubleTapToZoomEnabled = false
        lineChart.pinchZoomEnabled = false
        lineChart.scaleXEnabled = false
        lineChart.scaleYEnabled = false
        
        lineChart.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
        
        lineChart.legend.enabled = false
    }
}

extension PredictViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("I am here")
        return healthRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HealthRecordCell") as? HealthRecordCell else {return UITableViewCell()}
        
        let healthRecord = healthRecords[indexPath.row]
        print("second check")
        print(healthRecord)
        ageArray.append(Double(healthRecord.age.value!))
        glucoseArray.append(Double(healthRecord.glucose.value!))
        heightArray.append(Double(healthRecord.height.value!))
        weightArray.append(Double(healthRecord.weight.value!))
        bloodPressureArray.append(Double(healthRecord.bloodPressure.value!))
        
        print(ageArray)
        print(glucoseArray)
        print(heightArray)
        print(weightArray)
        print(bloodPressureArray)
        
        cell.configure(with: healthRecord)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 95
    }
    
}

extension PredictViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("selected")
        let healthRecord = healthRecords[indexPath.row]
        AlertService.updateAlert(in: self, healthRecord: healthRecord) {(age, glucose, height, weight, bloodPressure) in let dict: [String: Any?] = ["age": age, "glucose":glucose, "height":height, "weight":weight, "bloodPressure":bloodPressure]
            RealmService.shared.update(healthRecord, with: dict)
        }
    }
    
    func tableView(_ tableView : UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        guard editingStyle == .delete else { return }
        print("delete")
        let healthRecord = healthRecords[indexPath.row]
        RealmService.shared.delete(healthRecord)
    }
}








