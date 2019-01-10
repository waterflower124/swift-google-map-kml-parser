//
//  ForgetFirstAlertViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/10.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Alamofire

class ForgetFirstAlertViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView();
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstAlertUIView: UIView!
    @IBOutlet weak var secondAlertUIView: UIView!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    var emailText:String = ""
    var verification_code: String = ""
    var password: String = ""
    var confirm_password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        firstAlertUIView.isHidden = false
        secondAlertUIView.isHidden = true

    }
    
    @IBAction func sendEmailButtonAction(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//        performSegue(withIdentifier: "firstalerttologin_segue", sender: self)
        
        emailText = emailTextField.text!
        if(emailText.isEmpty) {
            self.createAlert(title: "Warning!", message: "Please input email address", success: false, type: "first")
            return
        }
        if(isValidEmail(email_str: emailText)) {
            
            startActivityIndicator()
            
            let requestDic = ["email": emailText]
            AF.request("http://u900336547.hostingerapp.com/api/forgot_password", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
                {
                    response in
                    switch response.result {
                    case .failure(let error):
                        print(error)
                        self.stopActivityIndicator()
                    case .success(let responseObject):
                        self.stopActivityIndicator()
                        let responseDict = responseObject as! NSDictionary
                        
                        let status = responseDict["status"] as! String
                        if(status == "success") {
                            self.createAlert(title: "Notice!", message: "We have sent verification code to your email. Please check your email inbox.", success: true, type: "first")
                        } else {
                            let error_type = responseDict["error_type"] as! String
                            if(error_type == "no_user") {
                                self.createAlert(title: "Warning!", message: "The user is not a registered user. Please try again.", success: false, type: "first")
                            }
                        }
                    }
            }
        
        } else {
            createAlert(title: "Warning!", message: "Invalid email address.", success: false, type: "first")
        }
    }
    
    @IBAction func sendEmailCancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPasswordButtonAction(_ sender: Any) {
        verification_code = verificationCodeTextField.text!
        password = passwordTextField.text!
        confirm_password = confirmTextField.text!
        
        if(verification_code.isEmpty) {
            createAlert(title: "Warning!", message: "Please input verification code.", success: false, type: "second")
            return
        }
        if(password.isEmpty) {
            createAlert(title: "Warning!", message: "Please input password.", success: false, type: "second")
            return
        }
        if(password.count < 6) {
            createAlert(title: "Warning!", message: "Please have to be at least 6 characters.", success: false, type: "second")
            return
        }
        if(password != confirm_password) {
            createAlert(title: "Warning!", message: "Password doesn't match.", success: false, type: "second")
            return
        }

         startActivityIndicator()
        
        let requestDic = ["email": emailText, "code": verification_code, "password": password]
        AF.request("http://u900336547.hostingerapp.com/api/change_password", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    self.stopActivityIndicator()
                case .success(let responseObject):
                    self.stopActivityIndicator()
                    let responseDict = responseObject as! NSDictionary
                    
                    let status = responseDict["status"] as! String
                    if(status == "success") {
                        self.createAlert(title: "Congratulations!", message: "Password has been updated.", success: true, type: "second")
                    } else {
                        let error_type = responseDict["error_type"] as! String
                        if(error_type == "error_code") {
                            self.createAlert(title: "Warning!", message: "Verification code is incorrect. Please enter the correct verification code.", success: false, type: "second")
                        }
                    }
                }
        }
    }
    
    @IBAction func resetPasswordCancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func createAlert(title: String, message:String, success: Bool, type:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            if success {
                if (type == "first") {
                    self.firstAlertUIView.isHidden = true
                    self.secondAlertUIView.isHidden = false
                } else if(type == "second") {
                    self.dismiss(animated: true, completion: nil)
                }
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
        
        overlayView.alpha = 0.0;
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
    
    func isValidEmail(email_str: String) -> Bool {
        let regExp = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regExp)
        return emailTest.evaluate(with: email_str)
    }

}
