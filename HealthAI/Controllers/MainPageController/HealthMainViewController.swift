//
//  HealthMainViewController.swift
//  HealthAI
//
//  Created by Feng Guo on 10/15/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Alamofire
import SwiftyJSON
import FirebaseDatabase
import ChameleonFramework
import FirebaseStorage
import FBSDKLoginKit
import GoogleSignIn

class HealthMainViewController: UIViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    //    @IBOutlet weak var cityLabel: UILabel!
    //    @IBOutlet weak var weatherImage: UIImageView!
    //    @IBOutlet weak var temperatureLabel: UILabel!
    
    //@IBOutlet weak var backgroundImageView: UIImageView!
    
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet weak var weatherConditionLbl: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    let user = Auth.auth().currentUser!
    
    var databaseRef : DatabaseReference!
    
    var storageRef: StorageReference!
    
    // @IBOutlet weak var workoutCardView: CardView!
    
    //@IBOutlet weak var conditionLabel: UILabel!
    
    
    @IBOutlet var workoutView: UIView!
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "47aa6d0303fe5a8186915aa57b079446"
    
    let weatherDataModel = WeatherDataModel()
    let locationManager = CLLocationManager()
    
    var sidebarView: SidebarView!
    var blackScreen : UIView!
    
    @IBOutlet var diabeteView: UIView!
    
    @IBOutlet var counterView: UIView!
    
    @IBOutlet weak var BMIView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        storageRef =  Storage.storage().reference()
        
        //MARK - Add CardView Gesture
        setupTapView()
        setupMenu()
        loadLocationManager()
        //need to extract out
        setupBackgroundView()
        
        self.definesPresentationContext = true
        print("View did load!!!!!")
    }
    
    //extract this function out
    
    func setupBackgroundView(){
        
        print("Set up background view called")
        
        DatabaseHelper.loadDatabaseImage(databaseRef: databaseRef, user: user, imageView: backgroundImageView,referenceName: "backgroundPhoto")
        
        
//        backgroundView.backgroundColor = UIColor.init(
//            gradientStyle: UIGradientStyle.leftToRight,
//            withFrame: backgroundView.frame,
//            andColors: [ UIColor.flatBlue, UIColor.orange, UIColor.green]
//        )
//
        self.workoutView.layer.cornerRadius = 10.0
        self.BMIView.layer.cornerRadius = 10.0
        self.diabeteView.layer.cornerRadius = 10.0
        self.counterView.layer.cornerRadius = 10.0

        self.counterView.clipsToBounds = true
    }
    
    
    @IBAction func StepsCalculator(_ sender: Any) {
        performSegue(withIdentifier: "goToSteps", sender: self)
    }
    
    
    @IBOutlet var stepButtton: UIButton!
    
    func setupTapView(){
        let workoutGesture = UITapGestureRecognizer(target: self, action: #selector(workouthandleTap(sender:)))
        self.workoutView.addGestureRecognizer(workoutGesture)
        
        //        let diabeteGesture = UITapGestureRecognizer(target: self, action: #selector(diabetehandleTap(sender:)))
        //        self.workoutView.addGestureRecognizer(diabeteGesture)
        //
        //        let caloriesCounterGesture = UITapGestureRecognizer(target: self, action: #selector(counterhandleTap(sender:)))
        //        self.workoutView.addGestureRecognizer(caloriesCounterGesture)
        //
        let BMIGesture = UITapGestureRecognizer(target: self, action: #selector(BMIhandleTap(sender:)))
        self.BMIView.addGestureRecognizer(BMIGesture)
        
        
        let DiabetesGesture = UITapGestureRecognizer(target: self, action: #selector(DiabeteshandleTap(sender:)))
        self.diabeteView.addGestureRecognizer(DiabetesGesture)
        
        
        let CounterGesture = UITapGestureRecognizer(target: self, action: #selector(CounterhandleTap(sender:)))
        self.counterView.addGestureRecognizer(CounterGesture)
        
        stepButtton.layer.cornerRadius = 10
        
        
    }
    
    
    
    @objc func workouthandleTap(sender:UITapGestureRecognizer){
        performSegue(withIdentifier: "goToWorkout", sender: self)
    }
    
    //    @objc func diabetehandleTap(sender:UITapGestureRecognizer){
    //        performSegue(withIdentifier: "goToDiabete", sender: self)
    //    }
    //
    //    @objc func counterhandleTap(sender:UITapGestureRecognizer){
    //        performSegue(withIdentifier: "goToCounter", sender: self)
    //    }
    //
    @objc func BMIhandleTap(sender:UITapGestureRecognizer){
        performSegue(withIdentifier: "goToBMI", sender: self)
    }
    
    
    @objc func DiabeteshandleTap(sender:UITapGestureRecognizer){
        performSegue(withIdentifier: "dashboardToDiabetesForm", sender: self)
    }
    
    @objc func CounterhandleTap(sender:UITapGestureRecognizer){
        performSegue(withIdentifier: "maintosub", sender: self)
    }
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            setupImagePickerController(type: "camera")
        }
    }
    
    @IBAction func loadImagePressed(_ sender: UIButton) {
        setupImagePickerController(type: "photolibrary")
    }
    
    func setupImagePickerController(type:String){
        
        let image = UIImagePickerController()
        image.delegate = self
        if type == "camera"{
            image.sourceType = UIImagePickerController.SourceType.camera
        }else if type == "photolibrary" {
            image.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        image.allowsEditing = true
        self.present(image,animated: true){
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            backgroundImageView.image = image
            
            DatabaseHelper.savePictureToStorage(storageRef: storageRef, databaseRef: databaseRef, user: user, imageView: backgroundImageView, imageName: "background_image",referenceImageName: "backgroundPhoto")
            
            
        }else{
            print("Can't get the background image.")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK - didUpdate the location methods which check the location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 1{
            locationManager.stopUpdatingLocation()
            print("logititude= \(location.coordinate.longitude)")
            
            let logititude = location.coordinate.longitude
            let latitude = location.coordinate.latitude
            let params : [String:String] = ["lat":String(latitude), "lon":String(logititude),"appId": APP_ID]
            getWeatherData(url:WEATHER_URL,parameters: params)
        }
    }
    
    func getWeatherData(url:String,parameters:[String:String]){
        
        Alamofire.request(url,method:.get,parameters:parameters).responseJSON { (response) in
            if response.result.isSuccess{
                print("Success! Got the weather data")
                
                let weatherJSON :JSON = JSON(response.result.value!)
                //print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }else{
                print("Error, \(String(describing: response.result.error))")
            }
        }
    }
    
    func updateWeatherData(json:JSON){
        
        weatherDataModel.temperature = Int(json["main"]["temp"].double! - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        weatherDataModel.weatherCondition = json["weather"][0]["description"].stringValue
        
        updateUIWeatherData(weatherDataModel: weatherDataModel)
        //        print(weatherDataModel.temperature)
        //        print(weatherDataModel.city)
        //        print(weatherDataModel.weatherIconName)
        //        print(weatherDataModel.weatherCondition)
        
    }
    
    
    //MARK - Update the Weather UI
    
    func updateUIWeatherData(weatherDataModel: WeatherDataModel){
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°C"
        weatherImage.image = UIImage(named: weatherDataModel.weatherIconName)
        weatherConditionLbl.text = weatherDataModel.weatherCondition
    }
    
    //MARK - didFailWithError which tell when the location update is fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    func loadLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    func setupMenu(){
        
        let btnMenu = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(btnMenuAction))
        btnMenu.tintColor=UIColor(red: 54/255, green: 55/255, blue: 56/255, alpha: 1.0)
        self.navigationItem.leftBarButtonItem = btnMenu
        
        sidebarView=SidebarView(frame: CGRect(x: 0, y: 0, width: 0, height: self.view.frame.height))
        sidebarView.delegate = self
        sidebarView.layer.zPosition=100
        self.view.isUserInteractionEnabled=true
        self.navigationController?.view.addSubview(sidebarView)
        
        blackScreen=UIView(frame: self.view.bounds)
        blackScreen.backgroundColor=UIColor(white: 0, alpha: 0.5)
        blackScreen.isHidden=true
        self.navigationController?.view.addSubview(blackScreen)
        blackScreen.layer.zPosition=99
        let tapGestRecognizer = UITapGestureRecognizer(target: self, action: #selector(blackScreenTapAction(sender:)))
        blackScreen.addGestureRecognizer(tapGestRecognizer)
        
    }
    
    @objc func btnMenuAction() {
        
        blackScreen.isHidden=false
        UIView.animate(withDuration: 0.5, animations: {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 250, height: self.sidebarView.frame.height)
        }) { (complete) in
            self.blackScreen.frame=CGRect(x: self.sidebarView.frame.width, y: 0, width: self.view.frame.width-self.sidebarView.frame.width, height: self.view.bounds.height+100)
        }
    }
    
    @objc func blackScreenTapAction(sender: UITapGestureRecognizer) {
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.5) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
    }
}

extension HealthMainViewController: SidebarViewDelegate {
    func sidebarDidSelectRow(row: Row) {
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
        switch row {
        case .editProfile:
            if let editprofileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfile") as? ProfileViewController
            {
                present(editprofileVC, animated: true, completion: nil)
            }
            
        case .calendar:
            
            if let calendarViewController = self.storyboard?.instantiateViewController(withIdentifier: "Calendar") as? CalendarViewController {
                let navigationController = UINavigationController(rootViewController: calendarViewController)
                self.navigationController?.present(navigationController, animated: true, completion: nil)
            }
            
//            if let calendarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Calendar") as? CalendarViewController
//            {
//                present(calendarVC, animated: true, completion: nil)
//            }
            
            print("Calendar")
        case .contact:
            print("Contact")
            
            
        case .signOut:
            print("Sign out!!")
            
            do {
                if Auth.auth().currentUser != nil {
                    try Auth.auth().signOut()
                    FBSDKLoginManager().logOut()
                    GIDSignIn.sharedInstance().signOut()
                    //must use dismiss the viewcontroller, should not use present
                    
                    //self.dismiss(animated: true, completion: nil)
                   performSegue(withIdentifier: "unwindSegueToLogin", sender: self)
                    
                }else{
                    print("There is no user log in. ")
                }
            }
            catch {
                print("error: there was a problem signing out")
            }
            break;
        case .none:
            break

        }
    }
}





