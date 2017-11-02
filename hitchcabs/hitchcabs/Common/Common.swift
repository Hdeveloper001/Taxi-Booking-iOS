//
//  Common.swift
//  hitchcabs
//
//  Created by iOSpro on 11/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import Foundation


class Common: NSObject{
    
    func changeCurrencyUnit(code : String) -> String{
        switch code {
        case "GBP":
            return "£"
        default:
            return "$"
        }
    }
    
    func updateFavoritesDatabase(index : Int){
        if (appuser.email != "")
        {
            let userTable = appuser.email.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "_")
            let usersRef = myFirebase.child(userTable).child("favourites")
            for i in 1 ... favouriteLocations.count
            {
                usersRef.ref.child("item" + String(i)).removeValue()
            }
            favouriteLocations.remove(at: index)
            
            for i in 1 ... favouriteLocations.count
            {
                let fav = favouriteLocations[i - 1]
                fav.saveToFirebase(index: i)
            }
        }
        else
        {
//            for i in 0 ... favouriteLocations.count{
//                userdefaults.removeObject(forKey: "title" + String(i + 1))
//                userdefaults.removeObject(forKey: "location" + String(i + 1))
//                userdefaults.removeObject(forKey: "lat" + String(i + 1))
//                userdefaults.removeObject(forKey: "lng" + String(i + 1))
//            }
            favouriteLocations.remove(at: index)
            for fav in favouriteLocations{
                fav.saveToFirebase()
            }
        }
    }
}
