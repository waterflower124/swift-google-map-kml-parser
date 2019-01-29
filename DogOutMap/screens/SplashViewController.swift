//
//  SplashViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/29.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Alamofire

class SplashViewController: UIViewController {

    var email: String = ""
    var password: String = ""
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if UserDefaults.standard.string(forKey: "email") != nil {
                self.email = UserDefaults.standard.string(forKey: "email")!
                self.password = UserDefaults.standard.string(forKey: "password")!
                if self.email != "" {
                    self.startActivityIndicator()
                
                    let requestDic = ["email": self.email, "password": self.password]
                    AF.request("http://u900336547.hostingerapp.com/api/login", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
                        {
                            response in
                            switch response.result {
                            case .failure(let error):
                                print(error)
                                self.stopActivityIndicator()
                                self.createAlert(title: "Warning!", message: "Network error.", success: false)
                                self.performSegue(withIdentifier: "splashtosignin_segue", sender: self)
                            case .success(let responseObject):
                                self.stopActivityIndicator()
                                let responseDict = responseObject as! NSDictionary
                                
                                let status = responseDict["status"] as! String
                                if(status == "success") {
                                    Global.token = responseDict["data"] as! String
                                    Global.user_fullname = responseDict["data1"] as! String
                                    Global.mail_address = self.email
                                   
                                    self.performSegue(withIdentifier: "splashtohome_segue", sender: self)
                                } else {
                                    let error_type = responseDict["error_type"] as! String
                                    self.performSegue(withIdentifier: "splashtosignin_segue", sender: self)
                                }
                            }
                    }
                } else {
                    self.performSegue(withIdentifier: "splashtosignin_segue", sender: self)
                }
            } else {
                self.performSegue(withIdentifier: "splashtosignin_segue", sender: self)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "splashtosignin_segue") {
            let firstalertVC = segue.destination as! SignInViewController
        } else if(segue.identifier == "splashtohome_segue") {
            let homeVC = segue.destination as! HomeViewController
        }
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
    
    func createAlert(title: String, message:String, success: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
