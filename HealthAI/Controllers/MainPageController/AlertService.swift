//
//  AlertService.swift
//  HealthAI
//
//  Created by Naresh Kumar on 03/12/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit

class AlertService {
    
    private init() {}
    
    static func addAlert(in vc: UIViewController,
                         completion: @escaping (Int?, Int?, Int?, Int?, Int?) -> Void) {
        
        let alert = UIAlertController(title: "Add Your Health Records", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (ageTF) in
            ageTF.placeholder = "Enter Your Age in Yrs"
        }
        
        alert.addTextField { (glucoseTF) in
            glucoseTF.placeholder = "Enter Your Glucose Value in mg/dL"
        }
        alert.addTextField { (heightTF) in
            heightTF.placeholder = "Enter Your Height in cms"
        }
        alert.addTextField { (weightTF) in
            weightTF.placeholder = "Enter Your Weight in Kgs"
        }
        alert.addTextField { (bloodPressureTF) in
            bloodPressureTF.placeholder = "Enter Your Blood Pressure in mmHg"
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let age = alert.textFields?.first?.text,
                let glucose = alert.textFields?[1].text,
                let heightString = alert.textFields?[2].text,
                let weightString = alert.textFields?[3].text,
                let bloodPressureString = alert.textFields?.last?.text
                else { return }
            
            //            let height = heightString == "" ? nil : Int(scoreString)
            //            let weight = weightString == "" ? nil : emailString
            
            completion(Int(age), Int(glucose), Int(heightString), Int(weightString), Int(bloodPressureString))
        }
        
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
    
    static func updateAlert(in vc: UIViewController,
                            healthRecord: HealthRecord,
                            completion: @escaping (Int?, Int?, Int?, Int?, Int?) -> Void) {
        
        let alert = UIAlertController(title: "Update Line", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (ageTF) in
            ageTF.placeholder = "Enter Your Age"
            ageTF.text = healthRecord.ageString()
        }
        
        alert.addTextField { (glucoseTF) in
            glucoseTF.placeholder = "Enter Your Glucose Value"
            glucoseTF.text = healthRecord.glucoseString()
        }
        alert.addTextField { (heightTF) in
            heightTF.placeholder = "Enter Your Height"
            heightTF.text = healthRecord.heightString()
        }
        alert.addTextField { (weightTF) in
            weightTF.placeholder = "Enter Your Weight"
            weightTF.text = healthRecord.weightString()
        }
        alert.addTextField { (bloodPressureTF) in
            bloodPressureTF.placeholder = "Enter Your Blood Pressure"
            bloodPressureTF.text = healthRecord.bloodPressureString()
        }
        
        let action = UIAlertAction(title: "Update", style: .default) { (_) in
            guard let age = alert.textFields?.first?.text,
                let glucose = alert.textFields?[1].text,
                let heightString = alert.textFields?[2].text,
                let weightString = alert.textFields?[3].text,
                let bloodPressureString = alert.textFields?.last?.text
                else { return }
            
            //            let score = scoreString == "" ? nil : Int(scoreString)
            //            let email = emailString == "" ? nil : emailString
            
            completion(Int(age), Int(glucose), Int(heightString), Int(weightString), Int(bloodPressureString))
        }
        
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
    
}
