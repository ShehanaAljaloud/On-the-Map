//
//  VerificationViewController.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 12/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI

class VerificationViewController : UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateMapView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func populateMapView(){
        
        var annotations = [MKPointAnnotation]()
        let lat = CLLocationDegrees(Storage.latitude)
        let lon = CLLocationDegrees(Storage.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(Storage.firstName) \(Storage.lastName)"
        annotation.subtitle = Storage.mediaURL
        annotations.append(annotation)
        
        let span = MKCoordinateSpan.init(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
       executeOnMain {
            self.mapView.addAnnotations(annotations)
            self.mapView.setRegion(region, animated: true)
            print("New location added to the Map View.")
        }
    }
    
    private func backToTabBarView(){
        executeOnMain {
            let alert = UIAlertController(title: "New location Added", message: "Successfully submitted a new location!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action) -> Void in
                self.performSegue(withIdentifier: "unwindMapView", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func Submit(_ sender: Any) {
        ParseClient.sharedInstance().postStudentLocation { (results, error) in
            
            if (error != nil) {
                executeOnMain {
                    self.displayAlert(title: "Submission Error", message: "Uable to complete your request")
                    self.dismiss(animated: true, completion: nil)
                }
                print(error as Any)
            } else {
                if let locationId = results {
                    Storage.locationID = locationId
                    self.backToTabBarView()
                }
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /////////////////
    func displayAlert(title:String, message:String?) {
        
        if let message = message {
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
}
