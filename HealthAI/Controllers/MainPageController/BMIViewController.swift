//
//  BMIViewController.swift
//  HealthAI
//
//  Created by Priscilla Imandi on 10/31/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit

class BMIViewController: UIViewController {

    
    var status: Int?
    @IBOutlet weak var GenderSC: UISegmentedControl!
    
    @IBOutlet weak var maintainButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var heightSlider: UISlider!
    @IBOutlet weak var heightValueLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightSlider: UISlider!
    @IBOutlet weak var weightValueLabel: UILabel!
    
    @IBOutlet weak var ageField: UITextField!
    
    @IBOutlet weak var ActivitySC: UISegmentedControl!
    
    @IBOutlet weak var calculatedValue: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var bmrValue: UILabel!
    @IBOutlet weak var ibwValue: UILabel!
    @IBOutlet weak var caloriesValue: UILabel!
    
    
    var current_gender:Int = 0
    var current_activity:Int = 0
    
    @IBOutlet weak var bmiscrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.title = "BMI Calculator"
        bmiscrollView.keyboardDismissMode = .onDrag
        
goButton.layer.cornerRadius = 20
        maintainButton.layer.cornerRadius = 20
        // Do any additional setup after loading the view.
    }
    @IBAction func maintainButton(_ sender: Any) {
        if calculatedValue.text == ""{
            let alert = UIAlertController(title: "Field is empty", message: "Please enter fields and click on Go!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {_ in alert.dismiss(animated: true, completion: nil)}
            ))
            self.present(alert,animated: true,completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if calculatedValue.text == ""{
            let alert = UIAlertController(title: "Field is empty", message: "Please enter fields and click on Go!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {_ in alert.dismiss(animated: true, completion: nil)}
            ))
            self.present(alert,animated: true,completion: nil)
        }
        else {
        if segue.identifier == "bmiToFood" {
            let dvc = segue.destination as! BMIfoodViewController
            dvc.newstatus = status!
        }
        }
        
    }
    @IBAction func goButton(_ sender: Any) {
        
        if self.ageField.text == ""{
            let alert = UIAlertController(title: "Field is empty", message: "Please fill in all the fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {_ in alert.dismiss(animated: true, completion: nil)}
            ))
            self.present(alert,animated: true,completion: nil)
        }
        else{
        self.calculateBMI()
        self.calculateBMR()
        self.calories()
        self.calculateIBW()
        }
    }

    @IBAction func genderChanged(_ sender: Any) {
        switch GenderSC.selectedSegmentIndex {
        case 0:
            current_gender = 0;
        case 1:
            current_gender = 1;
            
        default:
            current_gender = 0;
        }
    }
    @IBAction func heightValueChanged(_ sender: UISlider) {
        let currentValue = Float(sender.value)
        let heightStr = String(format: "%.0f", currentValue)
        heightValueLabel.text = "\(heightStr) inches"
    }
    @IBAction func weightValueChanged(_ sender: UISlider) {
        let currentValue = Float(sender.value)
        let weightStr = String(format: "%.0f", currentValue)
        weightValueLabel.text = "\(weightStr) pounds"
    }
    @IBAction func ActivityChanged(_ sender: Any) {
        switch ActivitySC.selectedSegmentIndex {
        case 0:
            current_activity = 0;
        case 1:
            current_activity = 1;
        case 2:
            current_activity = 2;
        case 3:
            current_activity = 3;
            
        default:
            current_activity = 0;
        }
    }
    private func calculateBMI() {
        let height: Float = heightSlider.value
        let weight: Float = weightSlider.value
        let bmi: Float = (weight / (height*height)) * 703
        let doubleStr = String(format: "%.2f", bmi)
        calculatedValue.text = "\(doubleStr)"
        self.changeStatus(bmi: bmi)
    }
    
    
    
    
    private func calories(){
        
        if(current_activity == 0){
            caloriesValue.text = "\((bmrValue.text! as NSString).floatValue * 1.2)"
        }
        else if(current_activity == 1){
            caloriesValue.text! = "\((bmrValue.text! as NSString).floatValue * 1.375)"
        }
        else if(current_activity == 2){
            caloriesValue.text! = "\((bmrValue.text! as NSString).floatValue * 1.55)"
        }
        else if(current_activity == 3){
            caloriesValue.text! = "\((bmrValue.text! as NSString).floatValue * 1.725)"
        }
        if let text = caloriesValue.text {
            print(text)
        }
        
    }
    private func calculateBMR(){
        let height: Float = heightSlider.value
        let weight: Float = weightSlider.value
        let age = ageField?.text
        var BMR:Float?
        //"\(answer)"
        if(current_gender == 0){
            let adjustetwt: Float = weight*6.23
            let adjustedht: Float = height*12.7
            let adjustedage: Float = (age! as NSString).floatValue*6.8
            BMR = 66.0
            BMR = BMR! + adjustedht + adjustetwt - adjustedage
            let doubleStr = String(format: "%.2f", BMR!)
            bmrValue.text = "\( doubleStr)"
        }
        else if(current_gender == 1){
            let adjustetwt: Float = weight*6.23
            let adjustedht: Float = height*12.7
            let adjustedage: Float = (age! as NSString).floatValue*6.8
            BMR = 665.0
            BMR = BMR! + adjustedht + adjustetwt - adjustedage
            let doubleStr = String(format: "%.2f", BMR!)
            bmrValue.text = "\(String(describing: doubleStr))"
            
        }
        
        
    }
    
    func calculateIBW(){
        let height: Float = heightSlider.value
        var IBW:Float?
        if(current_gender == 0){
            IBW = 106.0
            if(height > 60.0){
                IBW = IBW! + (height - 60)*6
            }
        }
        else if(current_gender == 1){
            IBW = 100.0
            if(height > 60.0){
                IBW = IBW! + (height - 60)*5
            }
        }
        let doubleStr = String(format: "%.2f", IBW!)
        ibwValue.text = "\(String(describing: doubleStr))"
    }
    
    
    
    private func changeStatus(bmi: Float) {
        if (bmi < 18) {
            statusLabel.text = "UNDER-WEIGHT"
            statusLabel.textColor = UIColor.blue
            status = 0
        } else if (bmi >= 18 && bmi < 25) {
            statusLabel.text = "Normal"
            statusLabel.textColor = UIColor.green
            status = 1
        } else if (bmi >= 25 && bmi < 30) {
            statusLabel.text = "Pre-Obese"
            statusLabel.textColor = UIColor.purple
            status = 2
        } else {
            statusLabel.text = "OBESE"
            statusLabel.textColor = UIColor.red
            status = 3
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
