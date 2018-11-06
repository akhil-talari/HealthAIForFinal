//
//  ProfileViewController.swift
//  HealthAI
//
//  Created by Feng Guo on 10/29/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet var bioTableView: UITableView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    
    var databaseRef : DatabaseReference!
    var storageRef : StorageReference!
    var LoginUser  = Auth.auth().currentUser!
    var imagePicker = UIImagePickerController()
    
    let bioList = ["Height","Weight","Glucose","Blood Pressure"]
    
    let unitList = ["cm","kg","mm/dl","mmHg"]
    
    let bio = ["height","weight","glucose","bloodpressure"]
    
    var numberOfvalues = ["","","",""]
    
    
    //MARK - Table View Set up
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bioCell", for: indexPath) as! BioCell
        
        cell.textLabel?.text = bioList[indexPath.row]
        
        // cell.bioLabel.text = bioList[indexPath.row]
        cell.unitLabel.text = unitList[indexPath.row]
        
        print("Values in the table view \(bio[indexPath.row])")
        
        
        print("Load database values!!!!")
        
        loadBioValues { (values) in
            
            self.numberOfvalues = values
            
            cell.valueLabel.text = self.numberOfvalues[indexPath.row]
        
            }
        
           return cell
        
        }
    
    typealias CompletionHandler = (_ newValue:[String]) -> Void
    
    func loadBioValues(completionHandler:@escaping CompletionHandler){
        
        var newValues = [String]()
        
        databaseRef.child("profile").child(LoginUser.uid).observeSingleEvent(of: .value, with:{ (snapshop) in
            
            let dictionary = snapshop.value as? NSDictionary
            
            
            for index in 0..<self.bio.count {
                let value = dictionary![self.bio[index]] as! String
                newValues.append(value)
                
            }
        
            completionHandler(newValues)
            
        })
        
    }
    
    
    //MARK - Build the edit method for the UITableView
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //let value = numberOfvalues[indexPath.row]
        
        let editAction = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            self.updateAction(indexPath: indexPath)
        }
        
        editAction.backgroundColor = UIColor.blue
        return [editAction]
        
    }
    
    
    //Set all the values to the database.
    func setBioValues(values: [String]){
        for index in 0..<bio.count {
            databaseRef.child("profile").child(LoginUser.uid).updateChildValues([bio[index]:values[index]])
        }
    }
    
    // Set Bio Value in the screen, no the database.
    func setBioValue(value: String, indexPath: IndexPath){
        databaseRef.child("profile").child(LoginUser.uid).updateChildValues([bio[indexPath.row]:value])
    }
    
    private func updateAction(indexPath: IndexPath){
        
        let alert = UIAlertController(title: "Update", message: "Update your Bio", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            guard let textField = alert.textFields?.first else{
                return
            }
            if let textToEdit = textField.text {
                if textToEdit.count == 0 {
                    return
                }else{
                    //let the label to be the textToEdit
                    self.numberOfvalues[indexPath.row] = textToEdit
                    print(self.numberOfvalues)
                    self.setBioValue(value: textToEdit, indexPath: indexPath)
                    //self.setBioValues(values: self.numberOfvalues)
                    self.bioTableView.reloadRows(at: [indexPath], with: .automatic)
                }
                
            }else{
                return
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField()
        guard let textField = alert.textFields?.first else{
            return
        }
        
        textField.placeholder = "Update your Personal Information"
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
        
    }
    
    //MARK - Set up the Profile UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getReferences()
        setProfilePicture(imageView: profileImageView)
        
        DatabaseHelper.loadDatabaseImage(databaseRef: databaseRef,user: LoginUser, imageView: profileImageView)
        DatabaseHelper.setDatabaseUsername(databaseRef: databaseRef, user: LoginUser, label: usernameLabel)
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
       //loadBioVlaues()
        
    }
    
    
    @objc func imageTapped()
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        let myActionSheet = UIAlertController(title: "Profile Picture", message: "Select the photo you want to change.", preferredStyle: .actionSheet)
        
        let viewPicture = UIAlertAction(title: "View Picture", style: .default) { (action) in
            
            let newImageView = UIImageView(image: self.profileImageView.image)
            
            newImageView.frame = self.view.frame
            
            newImageView.backgroundColor = UIColor.white
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            
            let tap = UIGestureRecognizer(target: self, action: #selector(self.dismissFullScreenImage(sender:)))
            newImageView.isUserInteractionEnabled = true
            newImageView.addGestureRecognizer(tap)
            
            self.view.addSubview(newImageView)
            
        }
        
        
        let photoGallery = UIAlertAction(title: "Photos", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
                
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
                
            }
        }
        
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
                
            }
        }
        
        myActionSheet.addAction(viewPicture)
        myActionSheet.addAction(photoGallery)
        myActionSheet.addAction(camera)
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(myActionSheet, animated: true, completion: nil)
        
        
    }
    
    //Check in the mobile is this one works?
    
    @objc func dismissFullScreenImage(sender : UITapGestureRecognizer){
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func getReferences(){
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
    
    internal func setProfilePicture(imageView: UIImageView){
        imageView.layer.cornerRadius = 50
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
    }
    

    
    @IBAction func saveProfileBtn(_ sender: UIButton) {
        
        //TODO - push all data which save in the screen to the database
        
        //setBioValues(values: numberOfvalues)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK -  Pick the image from the photo library
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        setProfilePicture(imageView: self.profileImageView)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = image
        }
        
        savePictureToStorage(imageView: profileImageView)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil, userInfo: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func savePictureToStorage(imageView: UIImageView){
        
        if let imageData: Data = imageView.image!.pngData() {
            
            let profilePicReference = storageRef.child("user_profile/\(LoginUser.uid)/profile_pic")
            
            DispatchQueue.main.async {
                profilePicReference.putData(imageData, metadata: nil) { (metadata, error) in
                    if error == nil {
                        print("Successfuly putting the data to the storage.")
                        
                        profilePicReference.downloadURL { (url, error) in
                            if let downloadUrl = url {
                                
                                print("Download URL:",downloadUrl)
                                self.databaseRef.child("profile").child(self.LoginUser.uid).updateChildValues(["photo":downloadUrl.absoluteString])
                                
                            }else {
                                print("error downloading from the url!")
                            }
                        }
                        
                    }else {
                        print("error putting the data into the storage.")
                    }
                }
            }
        }
    }
    

}
