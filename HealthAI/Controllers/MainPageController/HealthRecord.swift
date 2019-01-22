//
//  HealthRecord.swift
//  HealthAI
//
//  Created by Naresh Kumar on 03/12/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class HealthRecord:Object {
    let age = RealmOptional<Int>()
    let glucose = RealmOptional<Int>()
    let height = RealmOptional<Int>()
    let weight = RealmOptional<Int>()
    let bloodPressure = RealmOptional<Int>()
    
    convenience init(age:Int, glucose : Int, height:Int, weight: Int, bloodPressure:Int){
        self.init()
        self.age.value = age
        self.glucose.value = glucose
        self.height.value = height
        self.weight.value = weight
        self.bloodPressure.value = bloodPressure
    }
    
    func glucoseString() -> String? {
        guard let glucose = glucose.value else {return nil}
        return String(glucose)
    }
    func heightString() -> String? {
        guard let height = height.value else {return nil}
        return String(height)
    }
    func weightString() -> String? {
        guard let weight = weight.value else {return nil}
        return String(weight)
        
    }
    func bloodPressureString() -> String? {
        guard let bloodPressure = bloodPressure.value else {return nil}
        return String(bloodPressure)
    }
    func ageString() -> String? {
        guard let age = age.value else {return nil}
        return String(age)
    }
}
