//
//  HealthRecordCell.swift
//  HealthAI
//
//  Created by Naresh Kumar on 03/12/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit

class HealthRecordCell: UITableViewCell {
    
    @IBOutlet weak var ageLabel : UILabel!
    @IBOutlet weak var glucoseLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bloodPressureLabel: UILabel!
    
    
    func configure(with healthRecord: HealthRecord){
        ageLabel.text = healthRecord.ageString()
        glucoseLabel.text = healthRecord.glucoseString()
        heightLabel.text = healthRecord.heightString()
        weightLabel.text = healthRecord.weightString()
        bloodPressureLabel.text = healthRecord.bloodPressureString()
    }
    
}
