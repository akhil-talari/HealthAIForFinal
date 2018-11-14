//
//  WorkoutDetailViewController.swift
//  HealthAI
//
//  Created by Feng Guo on 14/11/18
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit
import RealmSwift

class WorkoutDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,DataTransferDelegate {
    
    @IBOutlet var myTableView: UITableView!
    
    var selectedWorkoutItem = WorkoutItem()
    
    var selectedSubworkoutItem = SubworkoutItem()
    var workoutHistoryItem = WorkoutHistoryItem()
    
    func userDidFinishedSubworkout(subworkoutItem: SubworkoutItem) {
        selectedSubworkoutItem.done = subworkoutItem.done
        //selectedSubworkoutItem.currentDate = subworkoutItem.currentDate
        selectedSubworkoutItem.time = subworkoutItem.time
        //selectedSubworkoutItem = subworkoutItem
        print("Subworkout Item: ", subworkoutItem.done)
        
        //print("Selected Subworkout Item: ",selectedSubworkoutItem.done)
        myTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        myTableView.reloadData()
    }
    
    @IBOutlet weak var contentText: UILabel!
    @IBOutlet weak var titleText: UILabel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        titleText.text = selectedWorkoutItem.title
        contentText.text = selectedWorkoutItem.content
        
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "End", style: .done, target: self, action: #selector(endWorkoutPressed(sender:)))
    }
    
    @objc func endWorkoutPressed(sender:AnyObject){
        //print("End")
        
        self.saveWorkout()
        self.navigationController?.popViewController(animated: true)
        
        
//        let alert = UIAlertController(title: "End Workout", message: "Are you sure you want to end your workout?", preferredStyle: .alert)
//
//        // add the actions (buttons)
//        alert.addAction(UIAlertAction(title: "End Workout", style: .default, handler: { (action) in
//            self.saveWorkout()
//            self.navigationController?.popViewController(animated: true)
//        }))
//
//        //alert.addAction(UIAlertAction(title: "Back to Workout", style: .cancel, handler: nil))
//
//        // show the alert
//        self.present(alert, animated: true, completion: nil)
    }
    
    func saveWorkout(){
        
        workoutHistoryItem.title = self.selectedWorkoutItem.title
        
        for index in 0..<self.selectedWorkoutItem.subworkouts.count {
            
            if selectedWorkoutItem.subworkouts[index].done == true {
                let subworkoutHistoryItem = SubworkoutHistoryItem()
                subworkoutHistoryItem.title = self.selectedWorkoutItem.subworkouts[index].title
                subworkoutHistoryItem.time = self.selectedWorkoutItem.subworkouts[index].time
                workoutHistoryItem.subworkoutItems.append(subworkoutHistoryItem)
            }
        }
        
        do{
            let realm = try Realm()
            try realm.write {
                realm.add(workoutHistoryItem)
            }
        }catch{
            print("Error using Realm!!")
        }
        
        print("workout Data save")
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedWorkoutItem.subworkouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "subworkoutCell", for: indexPath)
        
        cell.textLabel!.text = selectedWorkoutItem.subworkouts[indexPath.row].title
        
        if selectedWorkoutItem.subworkouts[indexPath.row].done == true{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToSubworkoutStopwatch", sender: self)
        
        selectedSubworkoutItem = selectedWorkoutItem.subworkouts[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSubworkoutStopwatch"{
            let seg = segue.destination as! WorkoutClockViewController
            seg.selectedSubworkoutItem = selectedSubworkoutItem
            seg.delegate = self
        }
    }
    
    

}
