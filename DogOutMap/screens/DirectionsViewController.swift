//
//  DirectionsViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/29.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class DirectionsViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    
    var address: String = ""
    var latitude: String = ""
    var longitude: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        self.addressLabel.text = self.address
        
        print("address: \(self.address)")
        print("latitude: \(self.latitude)")
        print("longitude: \(self.longitude)")
    }
    

    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func copyaddressButtonAction(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = self.address
        self.showToast(message: "Address is copied to clipboard.")
    }
    
    @IBAction func openGoogleMapButtonAction(_ sender: Any) {
        openGoogleMapApp(latitude: self.latitude, longitude: self.longitude, address: self.address)
    }
    
    @IBAction func openMapButtonActivity(_ sender: Any) {
        openMapApp(latitude: self.latitude, longitude: self.longitude, address: self.address)
    }
    
    func openGoogleMapApp(latitude:String, longitude:String, address:String) {
        
        var myAddress:String = address
        
//        //For Apple Maps
//        let testURL2 = URL.init(string: "http://maps.apple.com/")
        
        //For Google Maps
        let testURL = URL.init(string: "comgooglemaps-x-callback://")
        
        //For Google Maps
        if UIApplication.shared.canOpenURL(testURL!) {
            var direction:String = ""
            myAddress = myAddress.replacingOccurrences(of: " ", with: "+")
            
            direction = String(format: "comgooglemaps-x-callback://?daddr=%@,%@&x-success=sourceapp://?resume=true&x-source=AirApp", latitude, longitude)
            
            let directionsURL = URL.init(string: direction)
            if #available(iOS 10, *) {
                UIApplication.shared.open(directionsURL!)
            } else {
                UIApplication.shared.openURL(directionsURL!)
            }
        }
            //For Apple Maps
//        else if UIApplication.shared.canOpenURL(testURL2!) {
//            var direction:String = ""
//            myAddress = myAddress.replacingOccurrences(of: " ", with: "+")
//
//            //            var CurrentLocationLatitude:String = ""
//            //            var CurrentLocationLongitude:String = ""
//            //
//            //            if let latitude = UserDefaults.value(forKey: "CurrentLocationLatitude") as? Double {
//            //                CurrentLocationLatitude = "\(latitude)"
//            //                //print(myLatitude)
//            //            }
//            //
//            //            if let longitude = UserDefaults.value(forKey: "CurrentLocationLongitude") as? Double {
//            //                CurrentLocationLongitude = "\(longitude)"
//            //                //print(myLongitude)
//            //            }
//            let newLat: Double = Double(latitude)!
//            let newLng: Double = Double(longitude)!
//            let newLatStr = String(newLat + 0.00001)
//            let newLngStr = String(newLng + 0.00001)
//            direction = String(format: "http://maps.apple.com/?saddr=%@,%@&daddr=%@,%@", newLatStr, newLngStr, latitude, longitude)
//
//            let directionsURL = URL.init(string: direction)
//            if #available(iOS 10, *) {
//                UIApplication.shared.open(directionsURL!)
//            } else {
//                UIApplication.shared.openURL(directionsURL!)
//            }
//
//        }
            //For SAFARI Browser
        else {
            var direction:String = ""
            direction = String(format: "http://maps.google.com/maps?q=%@,%@", latitude, longitude)
            direction = direction.replacingOccurrences(of: " ", with: "+")
            
            let directionsURL = URL.init(string: direction)
            if #available(iOS 10, *) {
                UIApplication.shared.open(directionsURL!)
            } else {
                UIApplication.shared.openURL(directionsURL!)
            }
        }
    }
    
    func openMapApp(latitude:String, longitude:String, address:String) {
        
        var myAddress:String = address
        
        //For Apple Maps
        let testURL2 = URL.init(string: "http://maps.apple.com/")
        
//        //For Google Maps
//        let testURL = URL.init(string: "comgooglemaps-x-callback://")
        
//        //For Google Maps
//        if UIApplication.shared.canOpenURL(testURL!) {
//            var direction:String = ""
//            myAddress = myAddress.replacingOccurrences(of: " ", with: "+")
//
//            direction = String(format: "comgooglemaps-x-callback://?daddr=%@,%@&x-success=sourceapp://?resume=true&x-source=AirApp", latitude, longitude)
//
//            let directionsURL = URL.init(string: direction)
//            if #available(iOS 10, *) {
//                UIApplication.shared.open(directionsURL!)
//            } else {
//                UIApplication.shared.openURL(directionsURL!)
//            }
//        }
            //For Apple Maps
        if UIApplication.shared.canOpenURL(testURL2!) {
            var direction:String = ""
            myAddress = myAddress.replacingOccurrences(of: " ", with: "+")

            let newLat: Double = Double(latitude)!
            let newLng: Double = Double(longitude)!
            let newLatStr = String(newLat + 0.00001)
            let newLngStr = String(newLng + 0.00001)
            direction = String(format: "http://maps.apple.com/?saddr=%@,%@&daddr=%@,%@", newLatStr, newLngStr, latitude, longitude)

            let directionsURL = URL.init(string: direction)
            if #available(iOS 10, *) {
                UIApplication.shared.open(directionsURL!)
            } else {
                UIApplication.shared.openURL(directionsURL!)
            }

        }
            //For SAFARI Browser
        else {
            var direction:String = ""
            direction = String(format: "http://maps.google.com/maps?q=%@,%@", latitude, longitude)
            direction = direction.replacingOccurrences(of: " ", with: "+")
            
            let directionsURL = URL.init(string: direction)
            if #available(iOS 10, *) {
                UIApplication.shared.open(directionsURL!)
            } else {
                UIApplication.shared.openURL(directionsURL!)
            }
        }
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.lightGray
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 10.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
