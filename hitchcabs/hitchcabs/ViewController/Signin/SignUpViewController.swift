//
//  SignUpViewController.swift
//  hitchcabs
//
//  Created by iOSpro on 9/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import CountryPicker
import FirebaseAuth
import SVProgressHUD

class SignUpViewController: UIViewController , CountryPickerVCDelegate, CountryPickerDelegate {
    
    @IBOutlet var view_FirstnameBG: UIView!
    
    @IBOutlet var view_LastnameBG: UIView!
    
    @IBOutlet var view_CountryCodeBG: UIView!
    
    @IBOutlet var view_PhonenumberBG: UIView!
    
    @IBOutlet var view_EmailBG: UIView!
    
    @IBOutlet var view_PasswordBG: UIView!
    
    @IBOutlet var btn_SignUp: UIButton!
    
    @IBOutlet var btnPicker: UIButton!
    
    var picker: CountryPicker!
    
    @IBOutlet var txt_firstname: UITextField!
    @IBOutlet var txt_lastname: UITextField!
    
    @IBOutlet var txt_phonenumber: UITextField!
    @IBOutlet var txt_emailaddress: UITextField!
    
    @IBOutlet var txt_password: UITextField!
    
    var phoneNumber : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        txt_phonenumber.keyboardType = UIKeyboardType.decimalPad
        //get corrent country
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        //init Picker
        picker = CountryPicker()
        picker.countryPickerDelegate = self
        picker.showPhoneNumbers = true
        picker.setCountry(code!)
        
//        txt_emailaddress.text = String(getValueOfArray(index: 8181))
    }

    override func viewWillAppear(_ animated: Bool) {
        view_FirstnameBG.layer.cornerRadius = view_FirstnameBG.bounds.height/2
        view_FirstnameBG.clipsToBounds = true
        
        view_LastnameBG.layer.cornerRadius = view_LastnameBG.bounds.height/2
        view_LastnameBG.clipsToBounds = true
        
        view_CountryCodeBG.layer.cornerRadius = view_CountryCodeBG.bounds.height/2
        view_CountryCodeBG.clipsToBounds = true
        
        view_PhonenumberBG.layer.cornerRadius = view_PhonenumberBG.bounds.height/2
        view_PhonenumberBG.clipsToBounds = true
        
        view_EmailBG.layer.cornerRadius = view_EmailBG.bounds.height/2
        view_EmailBG.clipsToBounds = true
        
        view_PasswordBG.layer.cornerRadius = view_PasswordBG.bounds.height/2
        view_PasswordBG.clipsToBounds = true
        
        btn_SignUp.layer.cornerRadius = btn_SignUp.bounds.height/2
        btn_SignUp.clipsToBounds = true
    }
    
    @IBAction func pickCountry(_ sender: Any) {
        let countryPickerVC = self.storyboard?.instantiateViewController(withIdentifier: "CountryPickerVC") as! CountryPickerVC
        
        countryPickerVC.delegate = self
        countryPickerVC.modalPresentationStyle = .overCurrentContext
        self.present(countryPickerVC, animated: true, completion: nil)
        
    }
    
    func pick_country(code: String) {
        self.btnPicker.setTitle(code, for: .normal)
    }
    
//    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        //pick up anythink
        btnPicker.setTitle(phoneCode, for: .normal)
        phoneNumber = phoneCode.replacingOccurrences(of: "+", with: "")
        txt_phonenumber.text = ""
//        code.text = phoneCode
    }
    
    @IBAction func btnSignupClicked(_ sender: Any) {
        
        let alphaSet = CharacterSet.lowercaseLetters
        let numericSet = CharacterSet.decimalDigits
        
        if (txt_firstname.text == "")
        {
            let alert = UIAlertController(title: "Missing Field", message: "Please fill out First Name.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (txt_firstname.text?.lowercased().trimmingCharacters(in: alphaSet) != "")
        {
            let alert = UIAlertController(title: "Invalid First Name", message: "Please fill out Correct First Name.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        if (txt_lastname.text == "")
        {
            let alert = UIAlertController(title: "Missing Field", message: "Please fill out Last Name.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (txt_lastname.text?.lowercased().trimmingCharacters(in: alphaSet) != "")
        {
            let alert = UIAlertController(title: "Invalid Last Name", message: "Please fill out Correct Last Name.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        if (txt_phonenumber.text == "")
        {
            let alert = UIAlertController(title: "Missing Field", message: "Please fill out Phone Number.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (txt_phonenumber.text?.trimmingCharacters(in: numericSet) != "")
        {
            let alert = UIAlertController(title: "Invalid Phone Number", message: "Please fill out correct Phone Number.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (txt_emailaddress.text == "")
        {
            let alert = UIAlertController(title: "Missing Field", message: "Please fill out Email Address.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (!(txt_emailaddress.text?.contains("@"))! || !(txt_emailaddress.text?.contains(".com"))!)
        {
            let alert = UIAlertController(title: "Invalid Email Address", message: "Please fill out correct Email Address.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (txt_password.text == "")
        {
            let alert = UIAlertController(title: "Missing Field", message: "Please fill out Password.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: txt_emailaddress.text!, password: txt_password.text!, completion: { (user, error) in
            SVProgressHUD.dismiss()
            if user != nil
            {
                appuser.email = (user?.email)!
//                user?.getIDToken(completion: {(token, error) in
//                    appuser.fToken = token!
//                })
                userdefaults.set(appuser.email,forKey: "useremail")
                self.addFavoritesOnFirebase()
                
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
    
    func addFavoritesOnFirebase()
    {
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
                fav_location.saveToFirebase(index: index)
//                favouriteLocations.append(fav_location)
            }
        }
    }
    
    // for testing
    func getValueOfArray(index : Int) -> String{
        if (index == 0){
            return "0"
        }
        if (index == 1){
            return "1"
        }
        
        var f0 : String = "0"
        var f1 : String = "1"
        var fn : String = ""
        
        for _ in 2 ... index{
            fn = calcSum(f0: f0, f1: f1)
            f0 = f1;
            f1 = fn;
        }
        return fn
    }
    
    func calcSum(f0 : String, f1 : String) -> String {
        var fn : String = ""
        var overflowed : Bool = false
        let length : Int = f1.characters.count > f0.characters.count ? f0.characters.count : f1.characters.count
        let chars0 = Array(f0.characters)
        let chars1 = Array(f1.characters)
        for i in 0 ..< length{
            let c0 = String(chars0[f0.characters.count - i - 1])
            let c1 = String(chars1[f1.characters.count - i - 1])
            let vn = overflowed ? Int(c0)! + Int(c1)! + 1 : Int(c0)! + Int(c1)!
            overflowed = vn > 10 ? true : false
            let cn = String(vn).last!
            fn.insert(cn, at: fn.startIndex)
        
        }
        var vl = 0
        if f1.characters.count != f0.characters.count{
            vl = 1
        }
        if overflowed{
            vl += 1
        }
        if vl != 0{
            let cl = Array(String(vl).characters)[0]
            fn.insert(cl, at: fn.startIndex)
        }
        return fn
    }
    
    @IBAction func gotoSignIn(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewConroller") as! LoginViewConroller
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
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
