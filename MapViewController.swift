//
//  MapViewController.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 05/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getInfo()
    }
    
    func getInfo() {
        
        ParseClient.sharedInstance().getStudentLocation { (studentInfo, error) in
            if let studentInfo = studentInfo {
                Storage.studentLocations = studentInfo
                executeOnMain {
                    self.refresh()
                }
            } else {
                 executeOnMain {
                    self.displayAlert(title: "Invalid URL", message: "Unable to get student locations.")

                }
                print(error as Any)
            }
        }
    }
   
    func refresh() {
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        for student in Storage.studentLocations {
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.webURL
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pin!.canShowCallout = true
            pin!.pinTintColor = UIColor.red
            pin!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pin!.annotation = annotation
        }
        
        return pin
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.shared
            if let annotation = view.annotation, let urlString = annotation.subtitle {
                if let url = URL(string: urlString!) {
                    if app.canOpenURL(url) {
                        app.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    } else {
                        displayAlert(title: "Invalid URL", message: "Selected URL unable to be opened.")

                    }
                } else {
                    displayAlert(title: "Invalid URL", message: "Not a valid URL.")
                }
            }
        }
        
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

    
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
    
    


