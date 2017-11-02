//
//  ForgetPasswordVC.swift
//  hitchcabs
//
//  Created by iOSpro on 9/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit

class ForgetPasswordVC: UIViewController {
    
    @IBOutlet var view_EmailBG: UIView!
    
    @IBOutlet var btn_Submit: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view_EmailBG.layer.cornerRadius = view_EmailBG.bounds.height/2
        view_EmailBG.clipsToBounds = true
        
        btn_Submit.layer.cornerRadius = btn_Submit.bounds.height/2
        btn_Submit.clipsToBounds = true
    }

    
    @IBAction func btnClose_Clicked(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
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
