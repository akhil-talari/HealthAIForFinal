//
//  CalorieDataModel.swift
//  
//
//  Created by Naresh Kumar on 31/10/18.
//

import Foundation
import RealmSwift

class CalorieDataModel: Object{
    
    @objc dynamic var foodName:String = ""
    @objc dynamic var calorieCount:String = ""
    @objc dynamic var mealTypeData:String = ""
    @objc dynamic var amount:String = ""
    @objc dynamic var date:String = ""
    @objc dynamic var goalCal:String = ""
}
