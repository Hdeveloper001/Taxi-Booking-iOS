//
//  LoginViewConroller.swift
//  hitchcabs
//
//  Created by iOSpro on 9/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class LoginViewConroller: UIViewController {
    
    @IBOutlet var view_EmailBG: UIView!
    
    @IBOutlet var view_PasswordBG: UIView!
    @IBOutlet var txt_username: UITextField!
    @IBOutlet var txt_password: UITextField!
    
    @IBOutlet var btn_SignIn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view_EmailBG.layer.cornerRadius = view_EmailBG.bounds.height/2
        view_EmailBG.clipsToBounds = true
        
        view_PasswordBG.layer.cornerRadius = view_PasswordBG.bounds.height/2
        view_PasswordBG.clipsToBounds = true
        
        btn_SignIn.layer.cornerRadius = btn_SignIn.bounds.height/2
        btn_SignIn.clipsToBounds = true
    }

    
    @IBAction func btnForgotPasswordClicked(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPasswordVC") as! ForgetPasswordVC
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func btnSigninClicked(_ sender: Any) {
        
        if (txt_username.text == "")
        {
            
        }
        if (txt_password.text == "")
        {
            
        }
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: txt_username.text!, password:txt_password.text!, completion:{ (user, error) in
            SVProgressHUD.dismiss()
            if user != nil
            {
                appuser.email = (user?.email)!
                userdefaults.set(appuser.email,forKey: "useremail")
                self.syncFavoriteLocations()
                
                print("SignIn Successfully")// SignIn Successfully
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController                
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else
            {
                if let Error = error?.localizedDescription
                {
                    print(Error)
                    let alert = UIAlertController(title: "Alert", message: Error, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    print("Error")
                    let alert = UIAlertController(title: "Alert", message: "Network connection Failed!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        })      
    }

    func syncFavoriteLocations(){
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
                if (userdefaults.object(forKey: "fav_count") != nil)
                {
                    let str_count : String = userdefaults.object(forKey: "fav_count") as! String
                    let fav_count : Int = Int(str_count)!
                    
                    for index in 1 ... fav_count{
                        let fav_location : FavouriteLocation = FavouriteLocation()
                        fav_location.title = userdefaults.object(forKey: "title" + String(index)) as! String
                        fav_location.location = userdefaults.object(forKey: "location" + String(index)) as! String
                        fav_location.lat = userdefaults.object(forKey: "lat" + String(index)) as! String
                        fav_location.lng = userdefaults.object(forKey: "lng" + String(index)) as! String
                        fav_location.saveToFirebase()
                        favouriteLocations.append(fav_location)
                    }
                }
                isFavoriteLoaded = true
            } else {
                print("no results")
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    @IBAction func GotoSignUp(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
