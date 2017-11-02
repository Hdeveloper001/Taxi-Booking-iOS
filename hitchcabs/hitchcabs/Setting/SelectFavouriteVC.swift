//
//  SelectFavouriteVC.swift
//  hitchcabs
//
//  Created by iOSpro on 16/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit

class SelectFavouriteVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tv_Favourites: UITableView!
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    var indexpath : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv_Favourites.delegate = self
        tv_Favourites.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshAllDatas), for: .valueChanged)
        tv_Favourites.addSubview(refreshControl)
    }
    
    @objc func refreshAllDatas(){
        tv_Favourites.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tv_Favourites.reloadData()
    }
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddnew_Clicked(_ sender: Any) {
        
    }

    // MARK: - Tableview
    
    func numberOfSections(in tv_Favourites: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tv_Favourites: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tv_Favourites: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteLocations.count
    }
    
    func tableView(_ tv_Favourites: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv_Favourites.dequeueReusableCell(withIdentifier: "FavouriteTBCell") as! FavouriteTBCell
        
        cell.lb_title.text = favouriteLocations[indexPath.row].title
        cell.lb_location.text = favouriteLocations[indexPath.row].location        
        return cell
        
    }
    
    func tableView(_ tv_Favourites: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tv_Favourites.cellForRow(at: indexPath)! as! FavouriteTBCell
        
        if (indexpath == 0)
        {
            start_location = currentCell.lb_location.text!
//            CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            locationStart = CLLocation(latitude: CLLocationDegrees(favouriteLocations[indexPath.row].lat)!, longitude: CLLocationDegrees(favouriteLocations[indexPath.row].lng)!)
        }
        else
        {
            end_location = currentCell.lb_location.text!
            locationEnd = CLLocation(latitude: CLLocationDegrees(favouriteLocations[indexPath.row].lat)!, longitude: CLLocationDegrees(favouriteLocations[indexPath.row].lng)!)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            common.updateFavoritesDatabase(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)            
        }
    }
}
