//
//  RequestViewController.swift
//  hitchcabs
//
//  Created by iOSpro on 13/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GooglePlaces
import GooglePlacePicker
import SideMenu
import UberRides
import LyftSDK
import SVProgressHUD

class RequestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var viewMap: GMSMapView!
    @IBOutlet var tb_locations: UITableView!
    @IBOutlet var view_locations: UIView!
    @IBOutlet var btn_request: UIButton!
    @IBOutlet var lb_EST: UILabel!
    @IBOutlet var cabCollection: UICollectionView!
    
    var pickupMarker = GMSMarker()
    var destinationMarker = GMSMarker()
    
    var gotUberPrices : Bool = false
    var gotLyftPrices : Bool = false
    var isSorted : Bool = false
    
    var priceUber : String = ""
    var priceLyft : String = ""
    var priceTaxiCode : String = ""
    var priceTaxiFareFinder : String = ""
    
    var services = [Service]()
    var bestServices = [Service]()
    
//    var isCabSelectedList = [false, false, false, false, false]
    var selectedCabName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        tb_locations.delegate = self
        tb_locations.dataSource = self
        
        cabCollection.delegate = self
        cabCollection.dataSource = self
        
        view_locations.layer.cornerRadius = 16
        view_locations.clipsToBounds = true
        
        let menuRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "UISideMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
//        let camera: GMSCameraPosition = locationEnd.coordinate.latitude == 0 ? GMSCameraPosition.camera(withLatitude: locationStart.coordinate.latitude, longitude: locationStart.coordinate.longitude, zoom: 12.0) : GMSCameraPosition.camera(withLatitude: (locationStart.coordinate.latitude + locationEnd.coordinate.latitude) / 2 + 0.01, longitude: (locationStart.coordinate.longitude + locationEnd.coordinate.longitude) / 2, zoom: 12.0)
//        self.viewMap.camera = camera
//
        pickupMarker.position = CLLocationCoordinate2DMake(locationStart.coordinate.latitude, locationStart.coordinate.longitude)
        pickupMarker.map = self.viewMap
        
        destinationMarker.position = CLLocationCoordinate2DMake(locationEnd.coordinate.latitude, locationEnd.coordinate.longitude)
        destinationMarker.map = self.viewMap
        
        drawPath(startLocation: locationStart, endLocation: locationEnd)
        
        var _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        getPrices()
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
            
            let bounds = GMSCoordinateBounds(path: path)
            self.viewMap!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 0))
            
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: (locationStart.coordinate.latitude + locationEnd.coordinate.latitude) / 2 + 0.02 , longitude: (locationStart.coordinate.longitude + locationEnd.coordinate.longitude) / 2, zoom: 12.0)
            self.viewMap.camera = camera
        }
    }
    
    @objc func updateCounter() {
        if (gotUberPrices && gotLyftPrices && !isSorted)
        {
            findBestCabs()
            SVProgressHUD.dismiss()
        }
    }
    
    func findBestCabs(){
        if (services.count>0)
        {
            isSorted = true
            services = services.sorted(by: { $0.minPrice < $1.minPrice })
            var estSum = 0
            for index in 0 ..< 5
            {
                let serv = services[index]
                estSum += serv.estimateTime
                
            }
            let estH : Int = estSum / 5 / 3600
            let estM : Int = estSum / 5 / 60
            
            var est : String = ""
            if (estH > 0){
                est = String(estH) + " hours "
            }
            if (estM > 0){
                est += String(estM) + " mins"
            }
            lb_EST.text = "Estimated Journey Time: " + est
            cabCollection.reloadData()
        }
    }
    
    func getPrices()
    {
        SVProgressHUD.show()
        getUberPrice()
        getLyftPrice()
        getTaxiCodePrice()
        getTaxiFareFinderPrice()
        
    }
    
    func getUberPrice()
    {
        let client : RidesClient = RidesClient.init()
        client.fetchPriceEstimates(pickupLocation: locationStart, dropoffLocation: locationEnd, completion: {prices, response in
            if (prices.count>0){
                self.priceUber = common.changeCurrencyUnit(code: prices[0].currencyCode!) + (prices[0].lowEstimate?.description)! + " - " + (prices[0].highEstimate?.description)!
                for service in prices{
                    let uber = Service()
                    uber.name = (service.name?.lowercased().contains("uber"))! ? service.name! : "Uber" + service.name!
                    if (service.lowEstimate == nil || service.highEstimate == nil)
                    {
                        continue
                    }
                    uber.minPrice = Double(service.lowEstimate!)
                    uber.maxPrice = Double(service.highEstimate!)
                    uber.currencyCode = service.currencyCode!
                    uber.estimateTime = service.duration!
                    self.services.append(uber)
                }
            }
            self.gotUberPrices = true
        })
    }
    
    func getLyftPrice()
    {
        LyftAPI.costEstimates(from: locationStart.coordinate, to: locationEnd.coordinate) { result in
            if (result.value != nil && result.value?.count != 0)
            {
                let cost = result.value?.filter { $0.rideKind == .Standard }.first
                let mincost : String! = cost?.estimate?.minEstimate.amount.description
                let maxcost : String! = cost?.estimate?.maxEstimate.amount.description
                self.priceLyft = common.changeCurrencyUnit(code: (cost?.estimate?.maxEstimate.currencyCode)!) + mincost + " - " + maxcost
                
                for service in result.value!{
                    let lyft = Service()
                    lyft.name = service.displayName
                    let mincost : String! = service.estimate?.minEstimate.amount.description
                    let maxcost : String! = service.estimate?.maxEstimate.amount.description
                    lyft.minPrice = Double(mincost)!
                    lyft.maxPrice = Double(maxcost)!
                    lyft.currencyCode = (service.estimate?.maxEstimate.currencyCode)!
                    lyft.estimateTime = (service.estimate?.durationSeconds)!
                    self.services.append(lyft)
                }
            }
            self.gotLyftPrices = true
        }
    }
    
    func getTaxiCodePrice()
    {
        
    }
    
    func getTaxiFareFinderPrice()
    {
        
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

    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        btn_request.layer.cornerRadius = btn_request.bounds.height/2
        btn_request.clipsToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (start_location != "" && end_location != ""){
            drawPath(startLocation: locationStart, endLocation: locationEnd)
            
        }
        setMapBounds()
    }
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func RequestCab(_ sender: Any) {
//        let cell = cabCollection.visibleCells[1] as! CabCollectionViewCell
//        for index in 0 ... 7
//        {
//            let indexpath = IndexPath(row: index, section: 0)
//            let cabCell = self.cabCollection.dequeueReusableCell(withReuseIdentifier: "CabCollectionViewCell", for: indexpath) as! CabCollectionViewCell
////            let cabCell = cabCollection.cellForItem(at: indexpath) as! CabCollectionViewCell
//            let attributes: UICollectionViewLayoutAttributes? = self.cabCollection.layoutAttributesForItem(at: indexpath)
//            let cellRect: CGRect? = attributes?.frame
//            let cellFrameInSuperview: CGRect = self.cabCollection.convert(cellRect!, to: self.cabCollection.superview)
//
//            if (cellFrameInSuperview.origin.x > UIScreen.main.bounds.width / 6 + 5 && cellFrameInSuperview.origin.x < UIScreen.main.bounds.width / 2 - 5)
//            {
        
                if (selectedCabName.lowercased().contains("uber")){
                    let client : RidesClient = RidesClient.init()
                    let builder = RideParametersBuilder()
                    builder.pickupLocation = locationStart
                    builder.dropoffLocation = locationEnd
                    client.requestRide(parameters: builder.build(), completion: {(ride, response) -> Void in
                        if (ride != nil){
                            print("success!")
                        }
                        
                    })
                }
                if (selectedCabName.lowercased().contains("lyft")){
                    LyftDeepLink.requestRide(using: LyftDeepLinkBehavior.native, kind: RideKind.Standard, from: locationStart.coordinate, to: locationEnd.coordinate)
                }
//            }
//        }
        
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

    }
    
}

//MARK: - UICollectionViewDelegate
extension RequestViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CabCollectionViewCell = self.cabCollection.dequeueReusableCell(withReuseIdentifier: "CabCollectionViewCell", for: indexPath) as! CabCollectionViewCell
        
        let attributes: UICollectionViewLayoutAttributes? = self.cabCollection.layoutAttributesForItem(at: indexPath)
        let cellRect: CGRect? = attributes?.frame
        let cellFrameInSuperview: CGRect = self.cabCollection.convert(cellRect!, to: self.cabCollection.superview)
        
        if (indexPath.row == 0 || indexPath.row == 6)
        {
            cell.img_cab.image = UIImage()
            cell.lb_cab.text = ""
            cell.lb_price.text = ""
        }
        else
        {
            if (services.count >= indexPath.row)
            {
                let cab = services[indexPath.row - 1]
                cell.img_cab.image = UIImage(named: "img_cab")
                cell.lb_cab.text = cab.name
                cell.lb_price.text = common.changeCurrencyUnit(code: cab.currencyCode) + String(cab.minPrice) + " - " + String(cab.maxPrice)
            }
            
        }
        if (cellFrameInSuperview.origin.x > UIScreen.main.bounds.width / 6 + 5 && cellFrameInSuperview.origin.x < UIScreen.main.bounds.width / 2 - 5){
            cell.imgWidthConst.constant = 75
            cell.lb_cab.font = UIFont.systemFont(ofSize: 18)
            self.selectedCabName = cell.lb_cab.text!
        }
        else
        {
            cell.imgWidthConst.constant = 50
            cell.lb_cab.font = UIFont.systemFont(ofSize: 15)
        }
//        switch indexPath.row {
//        case 1: // Uber
//            cell.img_cab.image = UIImage(named: "img_cab")
//            cell.lb_cab.text = "Uber"
//            cell.lb_price.text = priceUber
////            cell.img_cablink.image = UIImage(named: "cab_start")
//            break
//        case 2: // Lyft
//            cell.img_cab.image = UIImage(named: "img_cab")
//            cell.lb_cab.text = "Lyft"
//            cell.lb_price.text = priceLyft
////            cell.img_cablink.image = UIImage(named: "cab_link")
//            break
//        case 3: // TaxiCode
//            cell.img_cab.image = UIImage(named: "img_cab")
//            cell.lb_cab.text = "TaxiCode"
//            cell.lb_price.text = priceTaxiCode
////            cell.img_cablink.image = UIImage(named: "cab_link")
//            break
//        case 4: // TaxiFareFinder
//            cell.img_cab.image = UIImage(named: "img_cab")
//            cell.lb_cab.text = "TaxiFareFinder"
//            cell.lb_price.text = priceTaxiFareFinder
////            cell.img_cablink.image = UIImage(named: "cab_link")
//            break
//        case 5: // TaxiFareFinder
//            cell.img_cab.image = UIImage(named: "img_cab")
//            cell.lb_cab.text = ""
//            cell.lb_price.text = ""
//            //            cell.img_cablink.image = UIImage(named: "cab_link")
//            break
//        default:
////            cell.img_cablink.image = UIImage(named: "cab_end")
//            cell.img_cab.image = UIImage()
//            cell.lb_cab.text = ""
//            cell.lb_price.text = ""
//            break
//        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width / 3 - 1, height: (UIScreen.main.bounds.width / 3 - 16) * 1.3 - 16 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //makeSelectedCellActivate(indexpath: indexPath)
//        collectionView.reloadData()
    }
    
//    func makeSelectedCellActivate(indexpath : IndexPath){
//
//        for index in 0 ..< 5
//        {
//            if (index == indexpath.row)
//            {
//                isCabSelectedList[index] = true
//            }
//            else
//            {
//                isCabSelectedList[index] = false
//            }
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = scrollView as? UICollectionView {
//            print("collectionview")
            self.cabCollection.reloadData()
//            if (scrollView.contentOffset.x > 0) {
//                //
//
//            }
        }
    }
  
}
