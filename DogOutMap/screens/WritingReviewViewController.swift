//
//  WritingReviewViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/26.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import AARatingBar
import Alamofire
import MarqueeLabel

class WritingReviewViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var mainRatingWindowView: UIView!
    @IBOutlet weak var mainwindowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainwindowWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var placenameLabel: MarqueeLabel!
    @IBOutlet weak var placeaddressLabel: MarqueeLabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var ratingBar: AARatingBar!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var remainCharacterLabel: UILabel!
    
    @IBOutlet weak var resultView: UIView!
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView();
    
    
    var bounds = UIScreen.main.bounds
    var width: Double = 0.0
    var height: Double = 0.0
    
    var full_name: String = ""
    var comment_text: String = ""
    var place_name: String = ""
    var address: String = ""
    var rating: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ////////   marquee label settting  /////////
        self.placenameLabel.text = self.place_name
        self.placenameLabel.type = .continuous
        self.placenameLabel.speed = .rate(50)
        self.placenameLabel.fadeLength = 0.0
        self.placenameLabel.trailingBuffer = 50.0
        self.placenameLabel.labelWillBeginScroll()
        
        self.placeaddressLabel.text = address
        self.placeaddressLabel.type = .continuous
        self.placeaddressLabel.speed = .rate(50)
        self.placeaddressLabel.fadeLength = 0.0
        self.placeaddressLabel.trailingBuffer = 50.0
        self.placeaddressLabel.labelWillBeginScroll()
        ////////////////////////////////////////
        
        self.mainRatingWindowView.isHidden = false
        self.resultView.isHidden = true

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        width = Double(bounds.size.width)
//        height = Double(bounds.size.height)
//        self.mainwindowWidthConstraint.constant = CGFloat(width * 0.93)
//        self.mainwindowHeightConstraint.constant = CGFloat(height * 0.75)
        ////  comment text view border setting  ////////
        self.commentTextView.layer.borderWidth = 1.0
        self.commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        //  rating bar setting  ////
        ratingBar.color = UIColor.black
        ratingBar.isEnabled = true
        ratingBar.isAbsValue = true
        ratingBar.canAnimate = true
        ratingBar.maxValue = 5
        ratingBar.value = 0.0
        
        ratingBar.ratingDidChange = { ratingValue in
            print("rating value: \(ratingValue)")
        }
        
        /////   set user full name
        full_name = Global.user_fullname
        self.usernameTextField.text = full_name
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitreviewButtonAction(_ sender: Any) {
        self.comment_text = self.commentTextView.text;
        if self.comment_text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            createAlert(title: "Warning!", message: "Please insert comments.")
            return;
        }
        self.rating = "\(self.ratingBar.value)"
        startActivityIndicator()
        let requestDic = ["token": Global.token, "place": self.place_name, "address": self.address, "rating": rating, "comment": self.comment_text]
        AF.request("http://u900336547.hostingerapp.com/api/report_app_review", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    self.stopActivityIndicator()
                case .success(let responseObject):
                    self.stopActivityIndicator()
                    let responseDict = responseObject as! NSDictionary
                    print("rating result: \(responseDict)")
                    let status = responseDict["status"] as! String
                    if(status == "success") {
                        self.mainRatingWindowView.isHidden = true
                        self.resultView.isHidden = false
                    } else {
                        let error_type = responseDict["error_type"] as! String
                        if(error_type == "token_error") {
                            self.createAlert(title: "Warning!", message: "Your user is expired Pleas sign in again.")
                        } else if(error_type == "registered") {
                            self.createAlert(title: "Warning!", message: "You are already submit review for this place.")
                        }
                    }
                }
        }
    }
    
    @IBAction func ratingresultcloseButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        self.comment_text = self.commentTextView.text
        let remainTextcount = 250 - self.comment_text.count
        self.remainCharacterLabel.text = String(remainTextcount) + " characters left"
//        if self.comment_text.count > 250 {
//            self.commentTextView.isEditable = false
//        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 251
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
