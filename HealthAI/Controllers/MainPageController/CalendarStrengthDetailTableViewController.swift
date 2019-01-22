//
//  CalendarStrengthDetailTableViewController.swift
//  HealthAI
//
//  Created by Feng Guo on 11/24/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit
import RealmSwift

class CalendarStrengthDetailTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, ExpandableHeaderViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var titleLabel: UILabel!
    
    let realm = try! Realm()
    
    var strengthSelectedDate = ""
    
    var strengthWorkoutHistories : Results<WorkoutHistoryItem>?
    
    func loadStrengthWorkoutHistoryData(){
        
        let strengthPredicate = NSPredicate(format: "currentDate==%@ AND type==%@", strengthSelectedDate,"Strength")
        strengthWorkoutHistories = realm.objects(WorkoutHistoryItem.self).filter(strengthPredicate)
    }
    
     var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Strength Workout Summary"
        
        loadStrengthWorkoutHistoryData()
        
        print("Strength Selected Date: ", strengthSelectedDate)
        
        for i in 0...strengthWorkoutHistories!.count-1 {
            
            var subworkouts = [String]()
            var times = [String]()
            
            if strengthWorkoutHistories![i].subworkoutItems.count > 0 {
                
                for j in 0...strengthWorkoutHistories![i].subworkoutItems.count-1 {
                    
                    subworkouts.append(strengthWorkoutHistories![i].subworkoutItems[j].title)
                    times.append(String(format:"%.1f",Double(strengthWorkoutHistories![i].subworkoutItems[j].time) / 60))
                    
                }
                
            }
            let section = Section(workoutTitle: strengthWorkoutHistories![i].title, subworkouts: subworkouts,times:times, expanded: false)
            
            sections.append(section)
        }
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].subworkouts.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (sections[indexPath.section].expanded) {
            return 60
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        header.customInit(title: sections[section].workoutTitle, section: section, delegate: self)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")! as! StrengthSubworkoutCell
        //cell.textLabel?.text = sections[indexPath.section].subworkouts[indexPath.row]
        cell.titleLabel.text = sections[indexPath.section].subworkouts[indexPath.row]
        cell.timeLabel.text = sections[indexPath.section].times[indexPath.row] + " min"
        return cell
    }
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        sections[section].expanded = !sections[section].expanded
        
        tableView.beginUpdates()
        for i in 0 ..< sections[section].subworkouts.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }
    
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let strengthWorkoutVC = StrengthWorkoutVC()
//        strengthWorkoutVC.customInit(workoutName: sections[indexPath.section].movies[indexPath.row])
//        tableView.deselectRow(at: indexPath, animated: true)
//        //self.navigationController?.pushViewController(strengthWorkoutVC, animated: true)
//    }
    
    
}
