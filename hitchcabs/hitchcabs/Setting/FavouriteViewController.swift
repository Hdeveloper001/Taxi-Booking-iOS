//
//  FavouriteViewController.swift
//  hitchcabs
//
//  Created by iOSpro on 14/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit

class FavouriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tv_Favourites: UITableView!
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
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
//        if (indexPath.row == 0)
//        {
//            cell.lb_pickupTitle.text = "Pickup Location"
//            cell.lb_pickupLocation.text = self.current_place
//            cell.icon_pickup.image = UIImage(named: "pickuppin")
//            cell.icon_process.image = UIImage(named: "rect_end")
//        }
//        else{
//            cell.lb_pickupLocation.text = self.destination_place
//        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            common.updateFavoritesDatabase(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tv_Favourites: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedIndex = indexPath.row
//        let autocompleteController = GMSAutocompleteViewController()
//        autocompleteController.delegate = self
//        present(autocompleteController, animated: true, completion: nil)
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
