//
//  AllMacros.swift
//  hitchcabs
//
//  Created by iOSpro on 11/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

var Loctions = [Location]()

var favouriteLocations = [FavouriteLocation]()

var myFirebase = Database.database().reference()

var appuser = AppUser()
let common = Common()

let userdefaults = UserDefaults.standard
var isFavoriteLoaded : Bool = false

var start_location : String = ""
var end_location : String = ""

var locationStart : CLLocation = CLLocation()
var locationEnd : CLLocation = CLLocation()

var direction = [GMSPolyline]()

let averageSpeed = 50000

let kAPI_TaxiCodeQuote = "https://api.taxicode.com/booking/quote/"
let kAPI_TaxiFare = "https://api.taxicode.com/booking/quote/"
