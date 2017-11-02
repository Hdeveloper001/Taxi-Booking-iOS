//
//  CountryPickerVC.swift
//  hitchcabs
//
//  Created by iOSpro on 10/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import CountryPicker


protocol CountryPickerVCDelegate {
    func pick_country(code:String)
}

class CountryPickerVC: UIViewController , CountryPickerDelegate {
    
    var delegate: CountryPickerVCDelegate?
    
    @IBOutlet var picker: CountryPicker!
    @IBOutlet var btnBackground: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        //init Picker
        picker.countryPickerDelegate = self
        picker.showPhoneNumbers = true
        picker.setCountry(code!)
        
    }

    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        //pick up anythink
        
        //        code.text = phoneCode
        
        self.delegate?.pick_country(code: phoneCode)
    }

    @IBAction func closePicker(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
