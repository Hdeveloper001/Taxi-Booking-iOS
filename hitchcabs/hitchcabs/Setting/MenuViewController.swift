//
//  MenuViewController.swift
//  hitchcabs
//
//  Created by iOSpro on 14/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import MessageUI

class MenuViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnContactUs_Clicked(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    @IBAction func btnPrivacy_Clicked(_ sender: Any) {
    }
    
    @IBAction func btnTerms_Clicked(_ sender: Any) {
    }
    
    @IBAction func btnLogout_Clicked(_ sender: Any) {
    }
    
    @IBAction func btnFavourites_Clicked(_ sender: Any) {
        
//        if (appuser.email == ""){
//            
//            return
//        }
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FavouriteViewController") as! FavouriteViewController
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["contact@hitchcabs.com"])
        mailComposerVC.setSubject("Sending EMail")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    private func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: Error!) {
        controller.dismiss(animated: true, completion: nil)
        
    }

}
