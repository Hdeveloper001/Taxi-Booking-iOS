//
//  EditFavouriteVC.swift
//  hitchcabs
//
//  Created by iOSpro on 14/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker
import Firebase
import FirebaseDatabase

class EditFavouriteVC: UIViewController {
    
    @IBOutlet var txt_title: UITextField!
    @IBOutlet var lb_location: UILabel!
    
    var lat : String = ""
    var lng : String = ""
    
    var ref : DatabaseReference!
//    var index : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
//        index = favouriteLocations.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSave_Clicked(_ sender: Any) {
        
        if (txt_title.text == "")
        {
            let alert = UIAlertController(title: "Missing Field", message: "Please fill out the Title.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (lb_location.text?.lowercased() == "select location")
        {
            let alert = UIAlertController(title: "Missing Field", message: "Please select your location.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
//        index += 1
        let fav_location = FavouriteLocation()
//        fav_location.id = index
        fav_location.title = txt_title.text!
        fav_location.location = lb_location.text!
        fav_location.lat = lat
        fav_location.lng = lng
        favouriteLocations.append(fav_location)
        fav_location.saveToFirebase()
        
        let alert = UIAlertController(title: "Location Saved", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)        
    }
    
    @IBAction func selectLocation(_ sender: Any) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }

    @IBAction func btnBack_Clicked(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EditFavouriteVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
                
        self.lb_location.text = place.formattedAddress!
        lat = String(place.coordinate.latitude)
        lng = String(place.coordinate.longitude)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

