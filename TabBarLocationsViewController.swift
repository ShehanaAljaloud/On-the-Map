//
//  ViewController.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 02/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//

import UIKit


class TabBarLocationsViewController:  UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isUserInteractionEnabled = true
    }
   
    @IBAction func logout(_ sender: Any) {
        UdacityClient.sharedInstance().logoutUser { (success, errorString) in
            if success {
                  executeOnMain {
                    self.dismiss(animated:true,completion:nil)
                  }
             }else {
                print(errorString as Any)
              }
        }
     }
    
    @IBAction func reload(_ sender: Any) {
        
        let mapViewController = self.viewControllers![0] as! MapViewController
        mapViewController.getInfo()
    }
    
    @IBAction func add(_ sender: Any) {
        
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddLocation")
        self.present(VC, animated: true, completion: nil)
    }
    
    
}



