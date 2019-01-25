//
//  HomeViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/10.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import ImageSlideshow
import SDWebImage
import AARatingBar

class HomeViewController: UIViewController, MKMapViewDelegate ,CLLocationManagerDelegate, XMLParserDelegate, UISearchBarDelegate {

    
    @IBOutlet weak var checkBoxRegion: UIView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var eatdrinkButton: UIButton!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var hotelButton: UIButton!
    @IBOutlet weak var beachButton: UIButton!
    @IBOutlet weak var workspaceButton: UIButton!
    @IBOutlet weak var supermarketButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    @IBOutlet weak var sportButton: UIButton!
    
    @IBOutlet weak var googleMapView: MKMapView!
    
    @IBOutlet weak var detailBox: UIView!
    @IBOutlet weak var detailBoxLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainName_label: UILabel!
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var address_label: UILabel!
    @IBOutlet weak var phone_label: UILabel!
    @IBOutlet weak var rating_label: UILabel!
    @IBOutlet weak var ratingBar: AARatingBar!
    @IBOutlet weak var slidshow: ImageSlideshow!
    @IBOutlet weak var website_label: UILabel!
    @IBOutlet weak var photocountLabel: UILabel!
    @IBOutlet weak var photogoogledescLabel: UILabel!
    
    
    
    //////  variable for google map    ////////
    let map_key = "AIzaSyAUfciCLFycnIUlrUUwjApQyhRyNr01o7g"
    var clLocationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var destinationLocation = CLLocation()
    var first_running = true//use for display annotation,  if update current location it's value is false
    
    ///////   for activityt indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    ////////   varibles for KML file read   ////////////////////
    
    
    var thisElementName = ""
    
    let DOCUMENT_TAG = "Document"
    let FOLDER_TAG = "Folder"
    let FOLDERNAME_TAG = "name"
    let PLACEMARK_TAG = "Placemark"
    let PLACEMARKNAME_TAG = "name"
    let DESCRIPTION_TAG = "description"
    let POINT_TAG = "Point"
    let COORDINATE_TAG = "coordinates"
    
    var isDocument = false
    var isFolder = false
    var isFolderStart = false
    var isFolderName = false
    var isPlacemark = false
    var isPlacemarkName = false
    var isDescription = false
    var isPoint = false
    var isCoordinate = false
    
    var folderName = ""
    var placemarkerName = ""
    var descriptionStr = ""
    var latitude_kml = ""
    var longitude_kml = ""
    
    var mapInfosArray: [mapInfo] = Array()
    //    var folderInfo: [[String]] = Array();
    var placeInfo: [Dictionary<String, String>] = Array()
    var eachItem = Dictionary<String, String>()
    
    var mapInforClass = mapInfo()
    
    var place_name = ""
    var address = ""
    var phone_nember = ""
    var website = ""
    var rating = 0.0
    var photo_array = [String]()
    var sdWebImageSource = [SDWebImageSource]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingBar.isEnabled = false;
        ratingBar.isAbsValue = false;
        ratingBar.canAnimate = false
        ratingBar.color = UIColor.red;
        ratingBar.maxValue = 5
        ratingBar.value = 0.0;
        
        ////////   slide    ///////////////////
        slidshow.slideshowInterval = 2.0;
        slidshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under);
        slidshow.contentScaleMode = UIView.ContentMode.scaleAspectFill;
        slidshow.pageIndicator = nil

        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        clLocationManager.requestWhenInUseAuthorization()
        clLocationManager.startUpdatingLocation()
        
        googleMapView.delegate = self
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let currentLocationCoor:CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: currentLocationCoor, span: span)
        googleMapView.setRegion(region, animated: true)
        self.googleMapView.showsUserLocation = true
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        ////  wesite lable tap add   ///////
        let tapWebsiteLabel: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.websitLabel_Tapped))
        self.website_label.addGestureRecognizer(tapWebsiteLabel)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func websitLabel_Tapped() {
        let url_str = self.website_label.text!
        if UIApplication.shared.canOpenURL(URL(string: url_str)!) {
            UIApplication.shared.open(URL(string: url_str)!, options: [:], completionHandler: nil);
        } else {
            createAlert(title: "Warning", message: "Cannot open Website");
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateSideDetailBox(action: "disappear", animated: false)
        startActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            /////     KML File read   /////////
            let kml_path = URL(string: "https://dogoutco.000webhostapp.com/dataForMap/doc.kml");
            if let parser = XMLParser(contentsOf: kml_path!) {
                parser.delegate = self
                parser.parse();
                
            } else {
                print("parser Error");
            }
        }
    }
    
    @IBAction func disappearButtonAction(_ sender: Any) {
        animateSideDetailBox(action: "disappear", animated: true)
    }
    
    @IBAction func categoryButtonAction(_ sender: Any) {
        if(checkBoxRegion.isHidden) {
            checkBoxRegion.isHidden = false;
            categoryButton.setImage(UIImage(named: "cancel"), for: UIControl.State.normal)
        } else {
            checkBoxRegion.isHidden = true;
            categoryButton.setImage(UIImage(named: "plus"), for: UIControl.State.normal)
        }
        if(!searchBar.isHidden) {
            searchBar.isHidden = true
            searchButton.setImage(UIImage(named: "search"), for: UIControl.State.normal)
        }
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        if(searchBar.isHidden) {
            searchBar.isHidden = false
            searchButton.setImage(UIImage(named: "left-arrow-black"), for: UIControl.State.normal)
        } else {
            searchBar.isHidden = true
            searchButton.setImage(UIImage(named: "search"), for: UIControl.State.normal)
        }
    }
    
    @IBAction func eatdrinkButtonAction(_ sender: Any) {
        if(eatdrinkButton.backgroundColor == UIColor.white) {
            eatdrinkButton.backgroundColor = UIColor.black
            showFolderPlaces(category: "Eat & Drink");
        } else {
            eatdrinkButton.backgroundColor = UIColor.white
            removeFolderPlaces(identity: "Eat & Drink");
        }
    }
    
    @IBAction func shopButtonAction(_ sender: Any) {
        if(shopButton.backgroundColor == UIColor.white) {
            shopButton.backgroundColor = UIColor.black
            showFolderPlaces(category: "Shops");
        } else {
            shopButton.backgroundColor = UIColor.white
            removeFolderPlaces(identity: "Shops");
        }
    }
    
    @IBAction func hotelButtonAction(_ sender: Any) {
        if(hotelButton.backgroundColor == UIColor.white) {
            hotelButton.backgroundColor = UIColor.black
            showFolderPlaces(category: "Hotels");
        } else {
            hotelButton.backgroundColor = UIColor.white
            removeFolderPlaces(identity: "Hotels");
        }
    }
    
    @IBAction func beachButtonAction(_ sender: Any) {
        if(beachButton.backgroundColor == UIColor.white) {
            beachButton.backgroundColor = UIColor.black
            showFolderPlaces(category: "Beach");
        } else {
            beachButton.backgroundColor = UIColor.white
            removeFolderPlaces(identity: "Beach");
        }
    }
    
    @IBAction func workspaceButtonAction(_ sender: Any) {
        if(workspaceButton.backgroundColor == UIColor.white) {
            workspaceButton.backgroundColor = UIColor.black
            showFolderPlaces(category: "Workspace");
        } else {
            workspaceButton.backgroundColor = UIColor.white
            removeFolderPlaces(identity: "Workspace");
        }
    }
    
    @IBAction func supermarketButtonAction(_ sender: Any) {
        if(supermarketButton.backgroundColor == UIColor.white) {
            supermarketButton.backgroundColor = UIColor.black
            showFolderPlaces(category: "Supermarkets");
        } else {
            supermarketButton.backgroundColor = UIColor.white
            removeFolderPlaces(identity: "Supermarkets");
        }
    }
    
    @IBAction func activityButtonAction(_ sender: Any) {
        if(activityButton.backgroundColor == UIColor.white) {
            activityButton.backgroundColor = UIColor.black
            showFolderPlaces(category: "Activities");
        } else {
            activityButton.backgroundColor = UIColor.white
            removeFolderPlaces(identity: "Activities");
        }
    }
    
    @IBAction func sportButtonAction(_ sender: Any) {
        if(sportButton.backgroundColor == UIColor.white) {
            sportButton.backgroundColor = UIColor.black
            showFolderPlaces(category: "Sports");
        } else {
            sportButton.backgroundColor = UIColor.white
            removeFolderPlaces(identity: "Sports");
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
        
        let currentLocationCoor:CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
        if(first_running) {
            first_running = false
            googleMapView.setCenter(currentLocationCoor, animated: true)
        } else {
            removeNearByPlaces(identity: "Current Location")
        }
        let annotation = customAnnotation(title:"My Location", subtitle:"Current Location", location:currentLocationCoor, place_id:"", place_description:"")
        
        self.googleMapView.addAnnotation(annotation)
    }
    
    func removeNearByPlaces(identity: String) {
        let filteredAnnotations = googleMapView.annotations.filter { annotation in
            if annotation is MKUserLocation { return false }          // don't remove MKUserLocation
            guard let subtitle = annotation.subtitle else { return false }  // don't remove annotations without any title
            return subtitle == identity                              // remove those whose title does not match search string
        }
        googleMapView.removeAnnotations(filteredAnnotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        if let subtitle = annotation.subtitle, subtitle == "Eat & Drink" {
            annotationView?.image = UIImage(named: "eat")
        } else if let subtitle = annotation.subtitle, subtitle == "Sports" {
            annotationView?.image = UIImage(named: "sports")
        } else if let subtitle = annotation.subtitle, subtitle == "Hotels" {
            annotationView?.image = UIImage(named: "hotel")
        } else if let subtitle = annotation.subtitle, subtitle == "Supermarkets" {
            annotationView?.image = UIImage(named: "supermarket")
        } else if let subtitle = annotation.subtitle, subtitle == "Shops" {
            annotationView?.image = UIImage(named: "shop")
        } else if let subtitle = annotation.subtitle, subtitle == "Activities" {
            annotationView?.image = UIImage(named: "activity")
        } else if let subtitle = annotation.subtitle, subtitle == "Workspace" {
            annotationView?.image = UIImage(named: "workspace")
        } else if let subtitle = annotation.subtitle, subtitle == "Beach" {
            annotationView?.image = UIImage(named: "beach")
        } else if let subtitle = annotation.subtitle, subtitle == "Current Location" {
            annotationView?.image = UIImage(named: "dog")
        } else if let subtitle = annotation.subtitle, subtitle == "" {
            annotationView?.image = UIImage(named: "marker")
        }
        
        annotationView?.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        animateSideDetailBox(action: "show", animated: true)
        
        sdWebImageSource.removeAll();
        guard let annotation = view.annotation as? customAnnotation else {
            return
        }
        destinationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        var place_id = annotation.place_id
        description_label.text = annotation.place_description
        let place_name_kml = annotation.title
        
        var findGoogleAPI = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?";
        findGoogleAPI += "input=" + place_name_kml!;
        findGoogleAPI += "&inputtype=textquery";
        findGoogleAPI += "&locationbias=circle:2000@" + String(describing: annotation.coordinate.latitude) + "," + String(describing: annotation.coordinate.longitude);
        findGoogleAPI += "&key=" + map_key;
        
        findGoogleAPI = findGoogleAPI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!;
        var url_placeID = URLRequest(url: URL(string: findGoogleAPI)!);
        url_placeID.httpMethod = "GET";
        
//        print("find API:   \(findGoogleAPI)");
        startActivityIndicator();
        
        let task_placeID = URLSession.shared.dataTask(with: url_placeID) {
            (data, response, error) in
            if(error == nil) {
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                if let data = jsonData as? Dictionary<String, AnyObject> {
                    if let result_status = data["status"] as? String {
                        if result_status == "ZERO_RESULTS" {
                            place_id = "";
                            print("get place id error")
                            print(data)
                        } else if result_status == "OK" {
                            if let candidates = data["candidates"] as? [Dictionary<String, AnyObject>] {
                                place_id = candidates[0]["place_id"] as? String
                                print("11111")
                                self.getPlaceDetails(of: place_id!)
                                return
                            }
                        }
                    }
                }
            } else {
                print("Communication Error")
            }
            DispatchQueue.main.async {
                if self.activityIndicator.isAnimating {
                    self.stopActivityIndicator()
                }
            }
            //group_findPlaceID.leave();
        }
        task_placeID.resume();
        let group_placeDetail = DispatchGroup();
        group_placeDetail.enter();
    }
    
    func getPlaceDetails(of place_id: String) {
        place_name = ""
        address = ""
        phone_nember = ""
        website = ""
        rating = 0.0
        photo_array = [String]()
        
        var strGoogleAPI = "https://maps.googleapis.com/maps/api/place/details/json?";
        strGoogleAPI += "placeid=" + place_id;
        strGoogleAPI += "&key=" + map_key;
        strGoogleAPI = strGoogleAPI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!;
        var urlRequest = URLRequest(url: URL(string: strGoogleAPI)!);
        urlRequest.httpMethod = "GET";
        
//        print("detail API:   \(strGoogleAPI)");
        let task_placeDetail = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            if(error == nil) {
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                if let data = jsonData as? Dictionary<String, AnyObject> {
                    if let result = data["result"] as? [String: Any] {
                        print("2222")
                        if(result["name"] == nil) {
                            self.place_name = "No place name"
                        } else {
                            self.place_name = result["name"] as! String
                        }
                        if(result["formatted_address"] == nil) {
                            self.address = "No address"
                        } else {
                            self.address = result["formatted_address"] as! String
                        }
                        if(result["formatted_phone_number"] == nil) {
                            self.phone_nember = "No phone number"
                        } else {
                            self.phone_nember = result["formatted_phone_number"] as! String
                        }
                        if(result["website"] == nil) {
                            self.website = "No website"
                        } else {
                            self.website = result["website"] as! String
                        }
                        if(result["rating"] == nil) {
                            self.rating = 0.0
                        } else {
                            self.rating = result["rating"] as! Double;
                        }
                        if(result["photos"] != nil) {
                            if let photos = result["photos"] as? [Dictionary<String, AnyObject>] {
                                var url_string = ""
                                for photo in photos {
                                    url_string = ""
                                    url_string = "https://maps.googleapis.com/maps/api/place/photo?maxwidth="
                                    url_string += String(photo["width"] as! Int)
                                    url_string += "&photoreference="
                                    url_string += photo["photo_reference"] as! String
                                    url_string = url_string + "&key=" + self.map_key
                                    
                                    self.photo_array.append(url_string)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.updateUI()
                        }
                        
                        return
                    }
                }
            } else {
                print("errrrrrrrrrrr");
            }
            DispatchQueue.main.async {
                if self.activityIndicator.isAnimating {
                    self.stopActivityIndicator();
                }
            }
            //            group_placeDetail.leave();
        }
        task_placeDetail.resume();
    }
    
    func updateUI() {
        if photo_array.count > 0 {
            do {
                let first_url_image = URL(string: photo_array[0]);
                let data = try Data(contentsOf: first_url_image!);
                DispatchQueue.main.async {
                    self.mainImageView.clipsToBounds = true
                    self.mainImageView.contentMode = UIView.ContentMode.scaleAspectFill
                    self.mainImageView.sd_setImage(with: first_url_image, completed: nil)
                }
            } catch {
                print("this is in the response \( error)")
            }
        } else {
            self.mainImageView.clipsToBounds = true
            self.mainImageView.contentMode = UIView.ContentMode.scaleAspectFit
            self.mainImageView.image = UIImage(named: "logo")
        }
        
        mainName_label.text = place_name
        name_label.text = place_name
        
        address_label.text = address
        phone_label.text = phone_nember
        website_label.text = website
//        website_button.setTitle(website, for: UIControlState.normal);
        rating_label.text = String(format:"%.1f", rating)
        self.ratingBar.updateValue(with: CGFloat(rating))
        
        
        if photo_array.count > 0 {
            for i in 0..<photo_array.count {
                sdWebImageSource.append(SDWebImageSource(urlString: photo_array[i])!)
            }
            slidshow.setImageInputs(sdWebImageSource)
            photocountLabel.text = String(photo_array.count)
            slidshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
        } else {
            let empty_imageArray = [ImageSource(imageString: "logo")]
            slidshow.setImageInputs(empty_imageArray as! [InputSource])
            slidshow.contentScaleMode = UIView.ContentMode.scaleAspectFit
            photocountLabel.text = "0"
        }
        
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating {
                self.stopActivityIndicator()
            }
            self.animateSideDetailBox(action: "show", animated: true)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating {
                self.stopActivityIndicator()
            }
        }
        thisElementName = elementName;
        if(elementName == DOCUMENT_TAG) {
            isDocument = true;
        }
        if(isDocument && elementName == FOLDER_TAG) {
            isFolder = true;
            isFolderStart = true;
            
            mapInforClass = mapInfo();
        }
        if(isFolderStart && !isPlacemark && elementName == FOLDERNAME_TAG) {
            isFolderName = true;
            
        }
        if(isFolderStart && elementName == PLACEMARK_TAG) {
            isPlacemark = true;
        }
        if(isPlacemark && elementName == PLACEMARKNAME_TAG) {
            isPlacemarkName = true;
        }
        if(isPlacemark && elementName == DESCRIPTION_TAG) {
            isDescription = true;
        }
        if(isPlacemark && elementName == POINT_TAG) {
            isPoint = true;
        }
        if(isPoint && elementName == COORDINATE_TAG) {
            isCoordinate = true;
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        var data = string.trimmingCharacters(in: .whitespacesAndNewlines);
        
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating {
                self.stopActivityIndicator()
            }
        }
        
        if(isFolder && thisElementName == FOLDER_TAG) {
        }
        if(isFolderName && thisElementName == FOLDERNAME_TAG) {
            folderName = data;
            mapInforClass.setFolderName(name: data);
            
        }
        if(isPlacemark && isPlacemarkName && thisElementName == PLACEMARKNAME_TAG) {
            placemarkerName.append(data);
            
        }
        if(isDescription && thisElementName == DESCRIPTION_TAG) {
            descriptionStr = data;
        }
        if(isCoordinate && thisElementName == COORDINATE_TAG) {
            let coordinate = data;
            let coordinateArray = coordinate.components(separatedBy: ",");
            latitude_kml = coordinateArray[0];
            longitude_kml = coordinateArray[1];
        }
        if(!isPlacemarkName && thisElementName == PLACEMARK_TAG) {
        }
        if(!isFolder && thisElementName == FOLDER_TAG) {
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating {
                self.stopActivityIndicator()
            }
        }
        if(elementName == DOCUMENT_TAG) {
            isDocument = false;
        }
        if(elementName == FOLDER_TAG) {
            isFolder = false;
            isFolderStart = false;
            
            mapInfosArray.append(mapInforClass);
        }
        if(isFolder && !isPlacemark && elementName == FOLDERNAME_TAG) {
            isFolderName = false;
        }
        if(elementName == PLACEMARK_TAG) {
            isPlacemark = false;
            var placeinfo: [String] = Array();
            placeinfo.append(placemarkerName);
            placeinfo.append(descriptionStr);
            placeinfo.append(latitude_kml);
            placeinfo.append(longitude_kml);
            
            placemarkerName = "";
            
            mapInforClass.appendPlaceInfo(placeInfo: placeinfo);
            
        }
        if(elementName == PLACEMARKNAME_TAG) {
            isPlacemarkName = false;
        }
        if(elementName == DESCRIPTION_TAG) {
            isDescription = false;
        }
        if(elementName == POINT_TAG) {
            isPoint = false;
        }
        if(elementName == COORDINATE_TAG) {
            isCoordinate = false;
        }
    }
    
    func animateSideDetailBox(action: String, animated isAnimated: Bool) {
        var xPosition = 0;
        if action != "show" {
            xPosition = -250
        }
        
        if isAnimated{
            UIView.animate(withDuration: 0.5, animations: {
                self.detailBoxLeadingConstraint.constant = CGFloat(xPosition)
                self.view.layoutIfNeeded()
            }) { (success) in
//                self.ratingBar.value = 1.2;
            }
        }else {
            self.detailBoxLeadingConstraint.constant = CGFloat(xPosition)
            self.view.layoutIfNeeded()
//            ratingBar.value = 1.2;
        }
    }
    
    func showFolderPlaces(category: String) {
        
        var latitude = 0.0;
        var longitude = 0.0;
        var place_name = "";
        var description = "";
        
        for mapinfoclass in mapInfosArray {
            if(mapinfoclass.getFolderName() == category) {
                let folderarray = mapinfoclass.getPlaceInfos();
                for placeinfo in folderarray {
                    if(placeinfo.count == 4) {
                        place_name = placeinfo[0];
                        description = placeinfo[1];
                        longitude = Double(placeinfo[2])!;
                        latitude = Double(placeinfo[3])!;
                    } else {
                        place_name = placeinfo[0];
                        description = "No Description";
                        longitude = Double(placeinfo[1])!;
                        latitude = Double(placeinfo[2])!;
                    }
                    
                    let annotation = customAnnotation(title:place_name, subtitle:category, location:CLLocationCoordinate2DMake(latitude, longitude), place_id:"", place_description:description);
                    
                    self.googleMapView.addAnnotation(annotation);
                }
            }
        }
    }
    
    func removeFolderPlaces(identity: String) {
        let filteredAnnotations = googleMapView.annotations.filter { annotation in
            if annotation is MKUserLocation { return false }          // don't remove MKUserLocation
            guard let subtitle = annotation.subtitle else { return false }  // don't remove annotations without any title
            return subtitle == identity                              // remove those whose title does not match search string
        }
        googleMapView.removeAnnotations(filteredAnnotations)
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func startActivityIndicator() {
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge;
        activityIndicator.color = UIColor.blue;
        view.addSubview(activityIndicator);
        activityIndicator.startAnimating();
        overlayView = UIView(frame:view.frame);
        overlayView.backgroundColor = UIColor.black;
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

class customAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var place_id: String?
    var place_description: String?
    
    init(title:String, subtitle:String, location:CLLocationCoordinate2D, place_id:String, place_description:String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = location
        self.place_id = place_id
        self.place_description = place_description
    }
}
