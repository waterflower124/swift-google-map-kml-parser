//
//  SignUpViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/9.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Alamofire
import AFNetworking

class SignUpViewController: UIViewController {

    @IBOutlet weak var termsRectangleButton: UIButton!
    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    var checkTerms = false
    var email: String =  ""
    var fullname: String =  ""
    var password: String = ""
    var confirm_password: String = ""
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        termsRectangleButton.backgroundColor = UIColor.white
        if(checkTerms) {
            termsRectangleButton.backgroundColor = UIColor.black
        } else {
            termsRectangleButton.backgroundColor = UIColor.white
        }
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    @IBAction func termsRectangleButtonAction(_ sender: Any) {
        checkTerms = !checkTerms
        if(checkTerms) {
            termsRectangleButton.backgroundColor = UIColor.black
        } else {
            termsRectangleButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func TermsAndConditionAction(_ sender: Any) {
        
    }
    
    @IBAction func signupButtonAction(_ sender: Any) {
        email = emailTextFiled.text!
        fullname = fullnameTextField.text!
        password = passwordTextField.text!
        confirm_password = confirmTextField.text!
        
//        email = "watersu91125@outlook.com"
//        fullname = "aaa"
//        password = "aaaaaa"
//        confirm_password = "aaaaaa"
        
        if(!checkTerms) {
            createAlert(title: "Warning!", message: "Please check Terms & Conditions.", success: false)
        } else {
            if(email.isEmpty) {
                createAlert(title: "Warning!", message: "Please input your Email address.", success: false)
                return
            }
            if(!isValidEmail(email_str: email)) {
                createAlert(title: "Warning!", message: "Please input valid Email address.", success: false)
                return
            }
            if(fullname.isEmpty) {
                createAlert(title: "Warning!", message: "Please input Full Name.", success: false)
                return
            }
            if(password.isEmpty) {
                createAlert(title: "Warning!", message: "Please input your password.", success: false)
                return
            }
            if(password.count < 6) {
                createAlert(title: "Warning!", message: "Password have to be at least 6 characters.", success: false)
                return
            }
            if(password != confirm_password) {
                createAlert(title: "Warning!", message: "Password doesn't match.", success: false)
                return
            }
            /***********************
             send email name password to server
             ************************/
            
            startActivityIndicator()
            
            let requestDic = ["email":email, "password": password, "confirm_password":confirm_password, "name": fullname]

//            let requestData = try? JSONSerialization.data(withJSONObject: requestDic, options:.prettyPrinted)
//            let requestJsonString = String(data: requestData!, encoding:.ascii)!

           
            AF.request("http://u900336547.hostingerapp.com/api/signup", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
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
                                self.createAlert(title: "Notice!", message: "We have sent verification code to your emal. Please check your email inbox.", success: true)
                            } else {
                                let error_type = responseDict["error_type"] as! String
                                if(error_type == "registered") {
                                    self.createAlert(title: "Warning!", message: "You are already registered. Please insert another mail address.", success: false)
                                } else if(error_type == "duplicate_name") {
                                    self.createAlert(title: "Warning!", message: "Username is duplicated. Please use another username.", success: false)
                                }
                            }
                        
                            
                    }
            }
        }
    }
    @IBAction func loginHereButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "signuptologin_segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "signuptologin_segue") {
            var loginVC = segue.destination as! SignInViewController
        } else if(segue.identifier == "signuptoverify_segue") {
            var verifyVC = segue.destination as! VerifyCodeViewController
            verifyVC.email = email
        }
    }
    
    func createAlert(title: String, message:String, success: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            if(success) {
                self.performSegue(withIdentifier: "signuptoverify_segue", sender: self)
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
    
    func isValidEmail(email_str: String) -> Bool {
        let regExp = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regExp)
        return emailTest.evaluate(with: email_str)
    }
}
