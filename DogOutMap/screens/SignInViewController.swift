//
//  SignInViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/9.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Alamofire

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var emailText: String = ""
    var passwordText: String = ""
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func ForgetPasswordAction(_ sender: Any) {
        performSegue(withIdentifier: "forgettofirstalert_segue", sender: self)
    }
    
    @IBAction func signInActionButton(_ sender: Any) {
        
//        self.performSegue(withIdentifier: "logintohome_segue", sender: self)
        
//        emailText = emailTextField.text!
//        passwordText = passwordTextField.text!
//        if(emailText.isEmpty) {
//            createAlert(title: "Warning!", message: "Please input your email address.", success: false)
//            return
//        }
//        if(!isValidEmail(email_str: emailText)) {
//            createAlert(title: "Warning!", message: "Please input valid email address.", success: false)
//            return
//        }
//        if(passwordText.isEmpty) {
//            createAlert(title: "Warning!", message: "Please input your password.", success: false)
//            return
//        }
//        if( passwordText.count < 6 ) {
//            createAlert(title: "Warning!", message: "Password have to be at least 6 characters.", success: false)
//            return
//        }
//
        startActivityIndicator()

//        let requestDic = ["email": emailText, "password": passwordText]
        let requestDic = ["email": "janghaoling@gmail.com", "password": "123456"]
        AF.request("http://u900336547.hostingerapp.com/api/login", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
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
                        Global.token = responseDict["data"] as! String
//                        Global.user_fullname = responseDict["user_name"] as! String
                        Global.mail_address = self.emailText
                        self.performSegue(withIdentifier: "logintohome_segue", sender: self)
                    } else {
                        let error_type = responseDict["error_type"] as! String
                        if(error_type == "no_user") {
                            self.createAlert(title: "Warning!", message: "You are not registered. Please create an account.", success: false)
                        } else if(error_type == "no_activated") {
                            self.createAlert(title: "Warning!", message: "User is not activated. Please check your mail address and password.", success: false)
                        } else if(error_type == "wrong_password") {
                            self.createAlert(title: "Warning!", message: "Password is incorrect. Please try again.", success: false)
                        }
                    }
                }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "forgettofirstalert_segue") {
            var firstalertVC = segue.destination as! ForgetFirstAlertViewController
        } else if(segue.identifier == "logintohome_segue") {
            var homeVC = segue.destination as! HomeViewController
        }
    }
    
    func createAlert(title: String, message:String, success: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func startActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.color = UIColor.blue
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
