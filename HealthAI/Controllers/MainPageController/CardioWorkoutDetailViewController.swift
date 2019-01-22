//
//  CardioWorkoutDetailViewController.swift
//  HealthAI
//
//  Created by Feng Guo on 11/12/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit
import RealmSwift
import MapKit
import CoreLocation

class CardioWorkoutDetailViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    var time:Int = 0
    var timer:Timer? = nil
    
    var traveledDistance:Double = 0
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    //var startDate: Date!
    var averageSpeed: Double = 0
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var map: MKMapView!
    @IBOutlet var startCardioWorkout: UIButton!
    
    var selectedCardioWorkoutItem = CardioWorkoutItem()
    var selectedWorkoutHistoryItem = WorkoutHistoryItem()
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Selected Cardio Workout: ",selectedCardioWorkoutItem.title)
        
        resetLabels()
        
        selectedWorkoutHistoryItem.title = selectedCardioWorkoutItem.title
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.activityType = .fitness
        
        map.mapType = MKMapType(rawValue: 0)!
        map.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        map.delegate = self
        
        manager.startMonitoringSignificantLocationChanges()
        manager.distanceFilter = 5
        
        //setupButtonImage(imageName: "play")
        setupButtons()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(endWorkoutPressed(sender:)))
        
    }
    
    
    @objc func endWorkoutPressed(sender:AnyObject){
        print("End")
        
        let alert = UIAlertController(title: "End Workout", message: "Are you sure you want to end your cardio workout?", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "End Workout", style: .default, handler: { (action) in
            self.saveWorkout()
            self.manager.stopUpdatingLocation()
            self.startLocation = nil
            self.lastLocation = nil
            self.navigationController?.popViewController(animated: true)
            //self.navigationController?.popToRootViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Back to Workout", style: .cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupButtons(){
        
        let normalGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap(_:)))
        startCardioWorkout.addGestureRecognizer(normalGesture)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector((longTap(_:))))
        startCardioWorkout.addGestureRecognizer(longGesture)
        
        startCardioWorkout.layer.cornerRadius = startCardioWorkout.frame.width / 2
        startCardioWorkout.clipsToBounds = true
        
        startCardioWorkout.setImage(UIImage(named: "play"), for: .normal)
        
        //setupButtonImage(imageName: "play")
    }
    
    @objc func longTap(_ sender:UIGestureRecognizer){
        startCardioWorkout.setImage(UIImage(named: "play"), for: .normal)
        if timer != nil {
            time = 0
            timer!.invalidate()
            timer = nil
            resetLabels()
            traveledDistance = 0
            manager.stopUpdatingLocation()
            self.startLocation = nil
            self.lastLocation = nil
            resetLabels()
            
        }else{
            // do the same thing as the above to set everything to 0
            time = 0
            resetLabels()
            traveledDistance = 0
            manager.stopUpdatingLocation()
            self.startLocation = nil
            self.lastLocation = nil
            //set the image back to the start button image
        }
    }
    
    func resetLabels(){
        speedLabel.text = String(format:"%.2f",0.00)
        totalDistance.text = String(format:"%.2f",0.00)
        timeLabel.text = "00:00:00"
    }
    
    func restartLocationManager(){
        manager.startUpdatingLocation()
        startLocation = nil
        lastLocation = nil
    }
    
    @objc func normalTap(_ sender:UIGestureRecognizer) {
        if timer != nil {
            startCardioWorkout.setImage(UIImage(named: "play"), for: .normal)
            // for timer
            timer!.invalidate()
            timer = nil
            //for location service
            manager.stopUpdatingLocation()
            
        }else{
            startCardioWorkout.setImage(UIImage(named: "pause"), for: .normal)
            restartLocationManager()
            speedLabel.text = String(format:"%.2f",0.00)
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(WorkoutClockViewController.action),userInfo: nil, repeats: true)
        }
    }
    
    func setupButtonImage(imageName:String){
        let startBtnimage = UIImageView()
        startBtnimage.frame = startCardioWorkout.frame
        startBtnimage.contentMode = .scaleAspectFit
        startBtnimage.clipsToBounds = true
        startBtnimage.image = UIImage(named: imageName)
        startCardioWorkout.addSubview(startBtnimage)
    }
    
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var totalDistance: UILabel!
    
    var speed: CLLocationSpeed = CLLocationSpeed()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        speed = (manager.location?.speed)!
        print("Speed:\(speed) mph ")
        
        speedLabel.text = String(format: "%.2f", speed) + " m/s"
        
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            
            traveledDistance += lastLocation.distance(from: location)
            //let straightDistance = startLocation.distance(from: location)
            
            //print("Traveled Distance:",  traveledDistance)
            //print("Straight Distance:", straightDistance)
            totalDistance.text = String(format: "%.2f", traveledDistance) + " M"
            //totalDistance.text = String(format: "%.2f", straightDistance) + " M"
            let polyline = MKPolyline(coordinates: [lastLocation.coordinate,location.coordinate], count: 2)
            self.map.addOverlay((polyline),level: .aboveRoads)
        }
        
        lastLocation = locations.last
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: span)
        
        self.map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        if (error as? CLError)?.code == .denied {
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    @objc func action(){
        time += 1
        let minutesPortion = String(format: "%02d", self.time / 60)
        let secondsPortion = String(format: "%02d", self.time % 60)
        let hoursPortion = String(format: "%02d", self.time / 3600)
        timeLabel.text = "\(hoursPortion):\(minutesPortion):\(secondsPortion)"
    }
    
    func saveWorkout(){
        let date = Helper.setupDateFormatter(format: "yyyy-MM-dd", date: Date())
        let dateTime = Helper.setupDateFormatter(format: "yyyy-MM-dd HH:mm", date: Date())
        selectedWorkoutHistoryItem.title = selectedCardioWorkoutItem.title
        print("Cardio workout title: ",selectedCardioWorkoutItem.title)
        
        selectedWorkoutHistoryItem.time = String(time)
        selectedWorkoutHistoryItem.type = selectedCardioWorkoutItem.type
        selectedWorkoutHistoryItem.averageSpeed = traveledDistance / Double(time)
        //selectedWorkoutHistoryItem.currentDate = dateFormatter.string(from: Date())
        selectedWorkoutHistoryItem.currentDate = date
        selectedWorkoutHistoryItem.currentDateTime = dateTime
        selectedWorkoutHistoryItem.totalDistance = traveledDistance
        do{
            let realm = try Realm()
            try realm.write {
                realm.add(selectedWorkoutHistoryItem)
            }
        }catch{
            print("Error using Realm!!")
        }
        
        print("workout Data save")
    }
    
}
