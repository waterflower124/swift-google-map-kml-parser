//
//  ReportLocationViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/27.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Alamofire
import MarqueeLabel

class ReportLocationViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var remainCharacterLabel: UILabel!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var placenameLabel: MarqueeLabel!
    @IBOutlet weak var addressLabel: MarqueeLabel!
    
    @IBOutlet weak var maincommentView: UIView!
    @IBOutlet weak var resultView: UIView!
    
    var mail_address: String = ""
    var comment_text: String = ""
    var place_name: String = ""
    var address: String = ""
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mailTextField.text = Global.mail_address
        self.placenameLabel.text = self.place_name
        self.addressLabel.text = self.address
        ////////   marquee label settting  /////////
        self.placenameLabel.text = self.place_name
        self.placenameLabel.type = .continuous
        self.placenameLabel.speed = .rate(50)
        self.placenameLabel.fadeLength = 0.0
        self.placenameLabel.trailingBuffer = 50.0
        self.placenameLabel.labelWillBeginScroll()
        
        self.addressLabel.text = address
        self.addressLabel.type = .continuous
        self.addressLabel.speed = .rate(50)
        self.addressLabel.fadeLength = 0.0
        self.addressLabel.trailingBuffer = 50.0
        self.addressLabel.labelWillBeginScroll()
        ////////////////////////////////////////

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        self.maincommentView.isHidden = false
        self.resultView.isHidden = true
        
        ////  comment text view border setting  ////////
        self.commentTextView.layer.borderWidth = 1.0
        self.commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.comment_text = self.commentTextView.text
        let remainTextcount = 250 - self.comment_text.count
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
    
    @IBAction func resultviewcloseButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportlocationButtonAction(_ sender: Any) {
        self.comment_text = self.commentTextView.text;
        if self.comment_text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            createAlert(title: "Warning!", message: "Please insert comments.")
            return;
        }
        
        startActivityIndicator()
        let requestDic = ["token": Global.token, "place": self.place_name, "address": self.address, "comment": self.comment_text]
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
                        self.maincommentView.isHidden = true
                        self.resultView.isHidden = false
                    } else {
                        let error_type = responseDict["error_type"] as! String
                        if(error_type == "token_error") {
                            self.createAlert(title: "Warning!", message: "Your account is expired. Please sign in again.")
                        } else if(error_type == "registered") {
                            self.createAlert(title: "Warning!", message: "You are already submit review for this place.")
                        }
                    }
                }
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
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    

}
