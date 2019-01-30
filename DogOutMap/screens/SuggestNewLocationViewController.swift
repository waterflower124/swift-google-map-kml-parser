//
//  SuggestNewLocationViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/27.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Alamofire

class SuggestNewLocationViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var locationnameTextField: UITextField!
    @IBOutlet weak var locationaddressTextField1: UITextField!
    @IBOutlet weak var locationaddressTextField2: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var remainCharacterLabel: UILabel!
    
    var location_name: String = ""
    var location_address: String = ""
    var location_address1: String = ""
    var location_address2: String = ""
    var city: String = ""
    var country: String = ""
    var comment: String = ""
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentTextView.layer.borderWidth = 1.0
        self.commentTextView.layer.borderColor = UIColor.lightGray.cgColor

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        self.mailTextField.text = Global.mail_address
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.comment = self.commentTextView.text
        let remainTextcount = 250 - self.comment.count
        self.remainCharacterLabel.text = String(remainTextcount) + " characters left"
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 251
    }
    

    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func suggestnewlocationButtonAction(_ sender: Any) {
        self.location_name = self.locationnameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.location_address1 = self.locationaddressTextField1.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.location_address2 = self.locationaddressTextField2.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.location_address = location_address1 + " " + location_address2
        self.city = self.cityTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.country = self.countryTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.comment = self.commentTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(self.location_name == "") {
            self.createAlert(title: "Warning!", message: "Pleas input location name")
            return
        }
        if(self.location_address1 == "") {
            self.createAlert(title: "Warning!", message: "Pleas input location address")
            return
        }
        if(self.city == "") {
            self.createAlert(title: "Warning!", message: "Pleas input location city")
            return
        }
        if(self.country == "") {
            self.createAlert(title: "Warning!", message: "Pleas input country")
            return
        }
        if(self.comment == "") {
            self.createAlert(title: "Warning!", message: "Pleas input comment")
            return
        }
        
        startActivityIndicator()
        let requestDic = ["token": Global.token, "place": self.location_name, "address": self.location_address, "country": self.country, "city": self.city, "comment": self.comment]
        AF.request("http://u900336547.hostingerapp.com/api/report_non_dogfriendly", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    self.stopActivityIndicator()
                case .success(let responseObject):
                    self.stopActivityIndicator()
                    let responseDict = responseObject as! NSDictionary
                    print("no dog friendly:  \(responseDict)")
                    print("rating result: \(responseDict)")
                    let status = responseDict["status"] as! String
                    if(status == "success") {
                        self.mainView.isHidden = true
                        self.resultView.isHidden = false
                    } else {
                        let error_type = responseDict["error_type"] as! String
                        if(error_type == "token_error") {
                            self.createAlert(title: "Warning!", message: "Your account is expired. Please sign in again.")
                        } else if(error_type == "registered") {
                            self.createAlert(title: "Warning!", message: "You are already suggest review for this place.")
                        }
                    }
                }
        }
        
    }
    
    @IBAction func resultViewCloseButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
}
