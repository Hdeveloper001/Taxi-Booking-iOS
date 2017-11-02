//
//  ViewController.swift
//  hitchcabs
//
//  Created by iOSpro on 9/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import GooglePlaces

class StartViewController: UIViewController, CLLocationManagerDelegate {

//    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (userdefaults.object(forKey: "useremail") != nil){
            appuser.email = userdefaults.object(forKey: "useremail") as! String
            if (appuser.email != "")
            {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chooseSignIn(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewConroller") as! LoginViewConroller
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }    
    
    @IBAction func chooseSignUp(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func skipSignIn(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

