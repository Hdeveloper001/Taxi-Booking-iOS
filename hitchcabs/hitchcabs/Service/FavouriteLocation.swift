//
//  FavouriteLocation.swift
//  hitchcabs
//
//  Created by iOSpro on 14/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FavouriteLocation: NSObject{
    
//    var id : Int = 0
    var title : String = ""
    var location : String = ""    
    var lat : String = ""
    var lng : String = ""
    
    func saveToFirebase() {
        
        let str_count = String(favouriteLocations.count)
        
        if (appuser.email != "")
        {
            let userTable = appuser.email.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "_")
            
            let usersRef = myFirebase.child(userTable).child("favourites")
            let dict = ["title" : self.title, "location" : location, "lat" : lat, "lng" : lng] as [String : Any]
            let thisUserRef = usersRef.child("item" + str_count)
            thisUserRef.setValue(dict)
        }
        else
        {
            userdefaults.set(self.title, forKey: "title" + str_count)
            userdefaults.set(self.location, forKey: "location" + str_count)
            userdefaults.set(self.lat, forKey: "lat" + str_count)
            userdefaults.set(self.lng, forKey: "lng" + str_count)
            
            userdefaults.set(str_count, forKey: "fav_count")
        }
    }
    
    func saveToFirebase(index : Int) {
        
        let str_count = String(index)
        
        if (appuser.email != "")
        {
            let userTable = appuser.email.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "_")
            
            let usersRef = myFirebase.child(userTable).child("favourites")
            let dict = ["title" : self.title, "location" : location, "lat" : lat, "lng" : lng] as [String : Any]
            let thisUserRef = usersRef.child("item" + str_count)
            thisUserRef.setValue(dict)
        }
    }
}
