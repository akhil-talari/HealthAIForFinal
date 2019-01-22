//
//  StepsViewController.swift
//  HealthAI
//
//  Created by Priscilla Imandi on 10/31/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit
import CoreMotion
import EventKit

class StepsViewController: UIViewController {
    
    @IBOutlet weak var statusTitle: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var avgPaceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var stepsHist: UIButton!
    @IBOutlet weak var calHist: UIButton!
    @IBOutlet weak var setBtn: UIButton!
    
    @IBOutlet weak var activityTypeLabel: UILabel!
    
    @IBOutlet weak var stepsView: UIView!
    @IBOutlet weak var stepsSubView: UIView!
    
    
    @IBOutlet weak var milesView: UIView!
    @IBOutlet weak var milesSubView: UIView!
    
    @IBOutlet weak var paceView: UIView!
    @IBOutlet weak var paceSubView: UIView!
    
    @IBOutlet weak var goalView: UIView!
    @IBOutlet weak var goalSubView: UIView!
    
    var record = 0
    var pass = 0
    var goal = 0
    
    var timer = Timer()
    var timerInterval = 1.0
    var timeElapsed:TimeInterval = 1.0
    //MARK: - Properties and Constants
    let stopColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let startColor = UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
    // values for the pedometer data
    var numberOfSteps:Int! = nil
    /*{ //this does not work. for demo purposes only.
     didSet{
     stepsLabel.text = "Steps:\(numberOfSteps)"
     }
     }*/
    @IBOutlet weak var remaining_goal: UILabel!
    var distance:Double! = nil
    var averagePace:Double! = nil
    var pace:Double! = nil
    
    @IBAction func sliderChange(_ sender: UISlider) {
        pass = Int(sender.value)
        setgoal.text = String(Int(sender.value))
    }
    
    @IBAction func setBtn(_ sender: UIButton) {
        goal = pass
        setgoal.text = "Goal set!"
        // create the alert
        let alert = UIAlertController(title: "Kudos", message: "Goal set!", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    //the pedometer
    var pedometer = CMPedometer()
    private let activityManager = CMMotionActivityManager()
    var savedEventId : String = ""

    
   
    @IBOutlet weak var setgoal: UILabel!
    override func viewDidLoad() {
        super.viewDidAppear(true)
        
        
        stepsView.layer.cornerRadius = 20
        stepsView.layer.masksToBounds = true;
        stepsSubView.layer.cornerRadius = 20
        stepsSubView.layer.masksToBounds = true;
        stepsSubView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        
        milesView.layer.cornerRadius = 20
        milesView.layer.masksToBounds = true;
        milesSubView.layer.cornerRadius = 20
        milesSubView.layer.masksToBounds = true;
        milesSubView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        
        paceView.layer.cornerRadius = 20
        paceView.layer.masksToBounds = true;
        paceSubView.layer.cornerRadius = 20
        paceSubView.layer.masksToBounds = true;
        paceSubView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        
        goalView.layer.cornerRadius = 20
        goalView.layer.masksToBounds = true;
        goalSubView.layer.cornerRadius = 20
        goalSubView.layer.masksToBounds = true;
        goalSubView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        stepsHist.layer.cornerRadius = 20
        calHist.layer.cornerRadius = 20
        setBtn.layer.cornerRadius = 20
        
        
        
        if(record == 0){
            loadit()
            record = record * Int(0.3)
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    private func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    self?.activityTypeLabel.text = "Walking"
                } else if activity.stationary {
                    self?.activityTypeLabel.text = "Stationary"
                } else if activity.running {
                    self?.activityTypeLabel.text = "Running"
                } else if activity.automotive {
                    self?.activityTypeLabel.text = "Automotive"
                }
            }
        }
    }
    
    
    
    
    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate as Date
        event.endDate = endDate as Date
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.save(event, span: .thisEvent)
            savedEventId = event.eventIdentifier
        } catch {
            print("Error Saving")
        }
    }
    
    func loadit(){
        checkAuthorizationStatus()
        startUpdating()
    }
        
        
    private func checkAuthorizationStatus() {
        switch CMMotionActivityManager.authorizationStatus() {
        case CMAuthorizationStatus.denied:
            //onStop()
            activityTypeLabel.text = "Not available"
            stepsLabel.text = "Not available"
        default:break
        }
    }
    
    private func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        } else {
            activityTypeLabel.text = "Not available"
        }
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        } else {
            stepsLabel.text = "Not available"
        }
    }
    
    private func startCountingSteps() {
        pedometer = CMPedometer()
        startTimer()
        pedometer.startUpdates(from: Date(), withHandler: { (pedometerData, error) in
            if let pedData = pedometerData{
                self.numberOfSteps = Int(truncating: pedData.numberOfSteps)
                //self.stepsLabel.text = "Steps:\(pedData.numberOfSteps)"
                if let distance = pedData.distance{
                    self.distance = Double(truncating: distance)
                }
                if let averageActivePace = pedData.averageActivePace {
                    self.averagePace = Double(truncating: averageActivePace)
                }
                if let currentPace = pedData.currentPace {
                    self.pace = Double(truncating: currentPace)
                }
            } else {
                self.numberOfSteps = nil
            }
        })
        //Toggle the UI to on state
        statusTitle.text = "Pedometer On"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "stepstostats" {
            let dvc = segue.destination as! StepsstatsViewController
            dvc.target1 = goal
        }
        
        if segue.identifier == "stepstocalorie" {
            let dvc = segue.destination as! stepscalorieViewController
            
        }
    }
  
    
    @IBAction func stepstostats(_ sender: Any) {
        performSegue(withIdentifier: "stepstostats", sender: sender)
      
    }
    
    
    @IBAction func stepstocalorie(_ sender: Any) {
        performSegue(withIdentifier: "stepstocalorie", sender: sender)
    }
    
    
    func startTimer(){
        if timer.isValid { timer.invalidate() }
        timer = Timer.scheduledTimer(timeInterval: timerInterval,target: self,selector: #selector(timerAction(timer:)) ,userInfo: nil,repeats: true)
    }
    
    
    func stopTimer(){
        timer.invalidate()
        displayPedometerData()
    }
    
    @objc func timerAction(timer:Timer){
        displayPedometerData()
    }
    
    func displayPedometerData(){
        timeElapsed += 1.0
        statusTitle.text = timeIntervalFormat(interval: timeElapsed)
        //Number of steps
        if let numberOfSteps = self.numberOfSteps{
            stepsLabel.text = String(format:"%i",numberOfSteps)
            
            remaining_goal.text = String(format: "%i", goal - numberOfSteps)
        }
        
        //distance
        if let distance = self.distance{
            distanceLabel.text = String(format:"%02.02f mi",miles(meters: distance))
        } else {
            distanceLabel.text = "0 mi"
        }
        
        //average pace
        if let averagePace = self.averagePace{
            avgPaceLabel.text = paceString(title: "", pace: averagePace)
        } else {
            avgPaceLabel.text =  paceString(title: "", pace: computedAvgPace())
        }
        
        //pace
        if let pace = self.pace {
            print(pace)
            //paceLabel.text = paceString(title: "", pace: pace)
        } else {
            //paceLabel.text = " "
            //paceLabel.text =  paceString(title: "", pace: computedAvgPace())
        }
    }
    
    
    func timeIntervalFormat(interval:TimeInterval)-> String{
        var seconds = Int(interval + 0.5) //round up seconds
        let hours = seconds / 3600
        let minutes = (seconds / 60) % 60
        seconds = seconds % 60
        return String(format:"%02i:%02i:%02i",hours,minutes,seconds)
    }
    // convert a pace in meters per second to a string with
    // the metric m/s and the Imperial minutes per mile
    func paceString(title:String,pace:Double) -> String{
        var minPerMile = 0.0
        let factor = 26.8224 //conversion factor
        if pace != 0 {
            minPerMile = factor / pace
        }
        let minutes = Int(minPerMile)
        let seconds = Int(minPerMile * 60) % 60
        return String(format: "%@ %02.2f m/s \n\t\t %02i:%02i min/mi",title,pace,minutes,seconds)
    }
    
    func computedAvgPace()-> Double {
        if let distance = self.distance{
            pace = distance / timeElapsed
            return pace
        } else {
            return 0.0
        }
    }
    
    func miles(meters:Double)-> Double{
        let mile = 0.000621371192
        return meters * mile
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


