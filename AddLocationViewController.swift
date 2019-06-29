//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 12/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBookUI


class AddLocationViewController :  UIViewController, UITextFieldDelegate  {
  
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var mediaURLField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    var address = ""
    var mediaURL = ""
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationField.delegate = self as? UITextFieldDelegate
        mediaURLField.delegate = self as? UITextFieldDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    
    @IBAction func findLocation(_ sender: Any) {
        
        if locationField.text!.isEmpty != false && mediaURLField.text!.isEmpty != false {
             displayAlert(title: "Incomplete Form", message: "Please fill out all fields")
        }
        else{
            address = locationField.text!
            Storage.mapString = locationField.text!
            Storage.mediaURL = mediaURLField.text!
            forwardGeocoding(address)

        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func forwardGeocoding(_ address: String) {
        showActivityIndicator(activityIndicator)
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        guard (error == nil) else {
            print("Unable to Forward Geocode Address (\(String(describing: error)))")
              displayAlert(title: "ERROR!", message: "Unable to Forward Geocode Address")
            
            return
        }
        
        if let placemarks = placemarks, placemarks.count > 0 {
            let placemark = placemarks[0]
            if let location = placemark.location {
                let coordinate = location.coordinate
                print("*** coordinate ***")
                print(placemark)
                
                Storage.latitude = coordinate.latitude
                Storage.longitude = coordinate.longitude
                
                if (placemark.locality != nil && placemark.administrativeArea != nil){
                    Storage.mapString = ("\(placemark.locality!),\(placemark.administrativeArea!)")
                }
                presentSubmitLocationView()
            } else {
                displayAlert(title: "NO Matching!", message: "No Matching Location Found")

            }
        }
    }
    
    func getUserName(){
        UdacityClient.sharedInstance().getUserData { (success, errorString) in
            guard (errorString == nil) else{
                executeOnMain {
                    self.displayAlert(title: "User Data", message: errorString)
                }
                return
            }
        }
    }
    
    private func presentSubmitLocationView(){
        self.hideActivityIndicator(self.activityIndicator)
        performSegue(withIdentifier: "goToVerificationScreenSegue", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func showActivityIndicator(_ activityIndicator: UIActivityIndicatorView){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
   func hideActivityIndicator(_ activityIndicator: UIActivityIndicatorView){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
 
    func displayAlert(title:String, message:String?) {
        
        if let message = message {
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    //Keyboard Methods
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        view.frame.origin.y = -(getKeyboardHeight(notification))
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        view.frame.origin.y = 0
    }
}
