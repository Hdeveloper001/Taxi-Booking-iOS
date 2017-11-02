//
//  HomeViewController.swift
//  hitchcabs
//
//  Created by iOSpro on 9/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GooglePlaces
import GooglePlacePicker
import SideMenu
import Firebase
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet var viewMap: GMSMapView!
    @IBOutlet var tb_locations: UITableView!
    @IBOutlet var view_locations: UIView!
    @IBOutlet var btn_hitchCabs: UIButton!
    
    var pickupMarker = GMSMarker()
    var destinationMarker = GMSMarker()
    var placesClient: GMSPlacesClient!
    
    var selectedIndex = 1
    
    var current_lat : Double = 0
    var current_lng : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tb_locations.delegate = self
        tb_locations.dataSource = self
        
        view_locations.layer.cornerRadius = 16
        view_locations.clipsToBounds = true

        placesClient = GMSPlacesClient.shared()
        let menuRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "UISideMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        getCurrentLocation()
        getFavouriteLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btn_hitchCabs.layer.cornerRadius = btn_hitchCabs.bounds.height/2
        btn_hitchCabs.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {        
        
        if (locationStart.coordinate.latitude != 0){
            pickupMarker.position = CLLocationCoordinate2DMake(locationStart.coordinate.latitude, locationStart.coordinate.longitude)
            pickupMarker.map = self.viewMap
        }
        if (locationEnd.coordinate.latitude != 0){
            destinationMarker.position = CLLocationCoordinate2DMake(locationEnd.coordinate.latitude, locationEnd.coordinate.longitude)
            destinationMarker.map = self.viewMap
        }
        if (locationStart.coordinate.latitude != 0){
            setMapBounds()
        }
        tb_locations.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.viewMap
                
                direction.append(polyline)
            }
            
        }
    }
    
    func ClearPath(startLocation: CLLocation, endLocation: CLLocation)
    {
    
        for polyline in direction
        {
            polyline.strokeColor = UIColor.clear
            polyline.map = nil
        }
        direction = [GMSPolyline]()
    }
    
    //MARK: - Geo location
    
    func getCurrentLocation(){
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    start_location = place.formattedAddress!
                    self.current_lat = place.coordinate.latitude
                    self.current_lng = place.coordinate.longitude
                    locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                    
                    self.tb_locations.reloadData()
                }
            }
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: self.current_lat, longitude: self.current_lng, zoom: 12.0)
            self.viewMap.camera = camera
            self.pickupMarker.position = CLLocationCoordinate2DMake(self.current_lat, self.current_lng)
            self.pickupMarker.map = self.viewMap
            
            self.setMapBounds()
        })
    }
    
    func setMapBounds()
    {
        if (locationEnd.coordinate.latitude == 0)
        {
            let path = GMSMutablePath()
            path.add(CLLocationCoordinate2DMake(locationStart.coordinate.latitude - 0.05, locationStart.coordinate.longitude - 0.05))
            path.add(CLLocationCoordinate2DMake(locationStart.coordinate.latitude - 0.05, locationStart.coordinate.longitude + 0.05))
            path.add(CLLocationCoordinate2DMake(locationStart.coordinate.latitude + 0.05, locationStart.coordinate.longitude + 0.05))
            path.add(CLLocationCoordinate2DMake(locationStart.coordinate.latitude + 0.05, locationStart.coordinate.longitude - 0.05))
            path.add(CLLocationCoordinate2DMake(locationStart.coordinate.latitude - 0.05, locationStart.coordinate.longitude - 0.05))
            
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: locationStart.coordinate.latitude, longitude: locationStart.coordinate.longitude, zoom: 12.0)
            self.viewMap.camera = camera
            
            let bounds = GMSCoordinateBounds(path: path)
            self.viewMap!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 0))
            
        }
        else
        {
            let top_lat = locationStart.coordinate.latitude > locationEnd.coordinate.latitude ? locationStart.coordinate.latitude + 0.03 : locationEnd.coordinate.latitude + 0.04
            let bottom_lat = locationStart.coordinate.latitude > locationEnd.coordinate.latitude ? locationEnd.coordinate.latitude - 0.03 : locationStart.coordinate.latitude - 0.03
            
            let left_lng = locationStart.coordinate.longitude > locationEnd.coordinate.longitude ? locationEnd.coordinate.longitude - 0.05 : locationStart.coordinate.longitude - 0.05
            let right_lng = locationStart.coordinate.longitude > locationEnd.coordinate.longitude ? locationStart.coordinate.longitude + 0.05 : locationEnd.coordinate.longitude + 0.05
            
            let path = GMSMutablePath()
            path.add(CLLocationCoordinate2DMake(top_lat, left_lng))
            path.add(CLLocationCoordinate2DMake(top_lat, right_lng))
            path.add(CLLocationCoordinate2DMake(bottom_lat, right_lng))
            path.add(CLLocationCoordinate2DMake(bottom_lat, left_lng))
//            path.add(CLLocationCoordinate2DMake(left_lat, top_lng))
            
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: (locationStart.coordinate.latitude + locationEnd.coordinate.latitude) / 2 + 0.02 , longitude: (locationStart.coordinate.longitude + locationEnd.coordinate.longitude) / 2, zoom: 12.0)
            self.viewMap.camera = camera
            
            let bounds = GMSCoordinateBounds(path: path)
            self.viewMap!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 0))
        }
    }
    
    func getFavouriteLocations(){
        if (isFavoriteLoaded)
        {
            isFavoriteLoaded = false
            return
        }
        if (appuser.email == ""){
            if (userdefaults.object(forKey: "fav_count") != nil)
            {
                let str_count : String = userdefaults.object(forKey: "fav_count") as! String
                let fav_count : Int = Int(str_count)!
                
                for index in 1 ... fav_count{
                    let fav_location : FavouriteLocation = FavouriteLocation()
                    if (userdefaults.object(forKey: "title" + String(index)) != nil)
                    {
                        fav_location.title = userdefaults.object(forKey: "title" + String(index)) as! String
                        fav_location.location = userdefaults.object(forKey: "location" + String(index)) as! String
                        fav_location.lat = userdefaults.object(forKey: "lat" + String(index)) as! String
                        fav_location.lng = userdefaults.object(forKey: "lng" + String(index)) as! String
                        favouriteLocations.append(fav_location)
                    }
                }
            }            
        }
        else
        {
            let userTable = appuser.email.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "_")
            
            myFirebase.child(userTable).child("favourites").observeSingleEvent(of: .value, with: { (favourites) in
                if let result = favourites.children.allObjects as? [DataSnapshot] {
                    for child in result {
                        //do your logic and validation here
                        let fav = FavouriteLocation()
//                        fav.id = (child.value as? [String:AnyObject])?["id"] as! Int
                        fav.title = (child.value as? [String:AnyObject])?["title"] as! String
                        fav.location = (child.value as? [String:AnyObject])?["location"] as! String
                        fav.lat = (child.value as? [String:AnyObject])?["lat"] as! String
                        fav.lng = (child.value as? [String:AnyObject])?["lng"] as! String
                        favouriteLocations.append(fav)
                    }
                } else {
                    print("no results")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }    
    
    @IBAction func HitchCabs_Clicked(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RequestViewController") as! RequestViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: - Tableview
    
    func numberOfSections(in tb_locations: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tb_locations: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tb_locations: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tb_locations: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tb_locations.dequeueReusableCell(withIdentifier: "PickLocationTBCell") as! PickLocationTBCell
        
        if (indexPath.row == 0)
        {
            cell.lb_pickupTitle.text = "Pickup Location"
            cell.lb_pickupLocation.text = start_location
            cell.icon_pickup.image = UIImage(named: "pickuppin")
            cell.icon_process.image = UIImage(named: "rect_end")
        }
        else{
            cell.lb_pickupLocation.text = end_location
        }
        
        return cell
        
    }
    
    func tableView(_ tb_locations: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (start_location != "" && end_location != ""){
            ClearPath(startLocation: locationStart, endLocation: locationEnd)
        }
        
        selectedIndex = indexPath.row
        
        let bounds = UIScreen.main.bounds
        
        let testFrame : CGRect = CGRect(x:bounds.width / 2 , y: bounds.height , width:120, height:100)
        let testView : UIView = UIView(frame: testFrame)
        testView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.view.addSubview(testView)
                
        let alertController = UIAlertController(title: "Choose Location", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.popoverPresentationController?.sourceView = testView
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        
        let pickupAction = UIAlertAction(title: "Enter Location", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            self.present(autocompleteController, animated: true, completion: nil)
        }
        
        let chooseAction = UIAlertAction(title: "Choose from Favorites", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectFavouriteVC") as! SelectFavouriteVC
            viewController.indexpath = self.selectedIndex
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        alertController.addAction(pickupAction)
        alertController.addAction(chooseAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
}

// Handle the user's selection.
extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

        
        switch selectedIndex {
        case 0:
//            pickupMarker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
//            pickupMarker.map = self.viewMap
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            start_location = place.formattedAddress!
            break
        default:
//            destinationMarker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
//            destinationMarker.map = self.viewMap
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            end_location = place.formattedAddress!
            break
        }
        
        if (start_location != "" && end_location != ""){
            drawPath(startLocation: locationStart, endLocation: locationEnd)
        }
        
        self.tb_locations.reloadData()
        
        setMapBounds()
        
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
