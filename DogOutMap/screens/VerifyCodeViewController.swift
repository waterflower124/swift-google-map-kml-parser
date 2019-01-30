//
//  VerifyCodeViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/10.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Alamofire

class VerifyCodeViewController: UIViewController {

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView();
    
    var email: String = ""
    var verification_code: String = ""
    
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func verifyButtonAction(_ sender: Any) {
        verification_code = verificationCodeTextField.text!
        if(verification_code == "") {
            self.createAlert(title: "Warning!", message: "Please input verification code.", success: false)
            return;
        }
        startActivityIndicator()
        
        let requestDic = ["email":email, "code": verification_code]
      
        
        AF.request("http://u900336547.hostingerapp.com/api/email_verify", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    self.stopActivityIndicator()
                case .success(let responseObject):
                    print(responseObject)
                    self.stopActivityIndicator()
                    let responseDict = responseObject as! NSDictionary
                    
                    let status = responseDict["status"] as! String
                    if(status == "success") {
                        self.createAlert(title: "Congratulations!", message: "Signup is successful.", success: true)
                    } else {
                        self.createAlert(title: "Warning!", message: "Verification code is incorect. Please input again.", success: false)
                    }
                }
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "verifytologin_segue") {
            var loginVC = segue.destination as! SignInViewController
        }
    }
    
    func createAlert(title: String, message:String, success: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            if(success) {
                self.performSegue(withIdentifier: "verifytologin_segue", sender: self)
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func startActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.color = UIColor.black
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        overlayView = UIView(frame:view.frame);
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.6;
        overlayView.layer.zPosition = 1
        view.addSubview(overlayView);
        UIApplication.shared.beginIgnoringInteractionEvents();
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating();
            self.overlayView.removeFromSuperview();
            if UIApplication.shared.isIgnoringInteractionEvents {
                UIApplication.shared.endIgnoringInteractionEvents();
            }
        }
    }
    

}
