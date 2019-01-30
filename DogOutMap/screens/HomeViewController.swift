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
import Alamofire
import MarqueeLabel
import GooglePlaces

class HomeViewController: UIViewController, MKMapViewDelegate ,CLLocationManagerDelegate, XMLParserDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var checkBoxRegion: UIView!
    @IBOutlet weak var suggestButtonRegionView: UIView!
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
    @IBOutlet weak var mainName_label: MarqueeLabel!
    @IBOutlet weak var name_label: MarqueeLabel!
    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var douout_ratingBar: AARatingBar!
    @IBOutlet weak var address_label: MarqueeLabel!
    @IBOutlet weak var phone_label: UILabel!
    @IBOutlet weak var rating_label: UILabel!
    @IBOutlet weak var ratingBar: AARatingBar!
    @IBOutlet weak var slidshow: ImageSlideshow!
    @IBOutlet weak var website_label: MarqueeLabel!
    @IBOutlet weak var photocountLabel: UILabel!
    @IBOutlet weak var photogoogledescLabel: UILabel!
    @IBOutlet weak var dogoutReviewView: UIView!
    
    @IBOutlet weak var detailBoxTransV: UIView!
    @IBOutlet weak var reportlocationView: UIView!
    
    ///////  variables for show reviews modal   //////
    @IBOutlet weak var dogoutReviewModalTransV: UIView!
    @IBOutlet weak var dogoutReviewModalView: UIView!
    @IBOutlet weak var modalPlaceNameLabel: MarqueeLabel!
    @IBOutlet weak var modalAddressLabel: MarqueeLabel!
    @IBOutlet weak var modalReviewLabel: UILabel!
    @IBOutlet weak var modalRatingBar: AARatingBar!
    @IBOutlet weak var modalCountReviewsLabel: UILabel!
    @IBOutlet weak var reportsListTableVIew: UITableView!
    
    var current_display_page = 1
    var reviews_array = [[String]]()
    var is_end: Bool = true
    var reach_end: Bool = false
    var totalReviewsCount: Int = 0;
    
    //////////////////////////////
    
    
    //////  variables for google map  /////////
    let map_key = "AIzaSyAUfciCLFycnIUlrUUwjApQyhRyNr01o7g"
    var clLocationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var destinationLocation = CLLocation()
    var first_running = true//use for display annotation,  if update current location it's value is false
    var selected_latitude: String = ""
    var selected_longitude: String = ""
    
    ///////   for activity indicator  //////////
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
    
    
    ///////// google places autocomplete  /////////
    lazy var filter:GMSAutocompleteFilter = {
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        return filter
    }()
    
    var googleAutoCompletePlaces = [GMSAutocompletePrediction]()
    
    @IBOutlet weak var googleAutoPlacesTableView: UITableView!
    ///////////////

    
    var first_place = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ////////   marquee label settting  /////////
        self.mainName_label.type = .continuous
        self.mainName_label.speed = .rate(50)
        self.mainName_label.fadeLength = 0.0
        self.mainName_label.trailingBuffer = 50.0
        self.mainName_label.labelWillBeginScroll()
        
        self.name_label.type = .continuous
        self.name_label.speed = .rate(50)
        self.name_label.fadeLength = 0.0
        self.name_label.trailingBuffer = 50.0
        self.name_label.labelWillBeginScroll()
        
        self.address_label.type = .continuous
        self.address_label.speed = .rate(50)
        self.address_label.fadeLength = 0.0
        self.address_label.trailingBuffer = 50.0
        self.address_label.labelWillBeginScroll()
        
        self.website_label.type = .continuous
        self.website_label.speed = .rate(50)
        self.website_label.fadeLength = 0.0
        self.website_label.trailingBuffer = 50.0
        self.website_label.labelWillBeginScroll()
        
        self.modalPlaceNameLabel.type = .continuous
        self.modalPlaceNameLabel.speed = .rate(50)
        self.modalPlaceNameLabel.fadeLength = 0.0
        self.modalPlaceNameLabel.trailingBuffer = 50.0
        self.modalPlaceNameLabel.labelWillBeginScroll()
        
        self.modalAddressLabel.type = .continuous
        self.modalAddressLabel.speed = .rate(50)
        self.modalAddressLabel.fadeLength = 0.0
        self.modalAddressLabel.trailingBuffer = 50.0
        self.modalAddressLabel.labelWillBeginScroll()
////////////////////////////////////////////////////////////
        
        //////  google rating bar  ///////
        ratingBar.isEnabled = false
        ratingBar.isAbsValue = false
        ratingBar.canAnimate = false
        ratingBar.color = UIColor.red
        ratingBar.maxValue = 5
        ratingBar.value = 0.0
        
        //////  dogout rating bar  ///////
        douout_ratingBar.isEnabled = false
        douout_ratingBar.isAbsValue = false
        douout_ratingBar.canAnimate = false
        douout_ratingBar.color = UIColor.black
        douout_ratingBar.maxValue = 5
        douout_ratingBar.value = 0.0
        
        //////  modal rating bar  ///////
        modalRatingBar.isEnabled = false
        modalRatingBar.isAbsValue = false
        modalRatingBar.canAnimate = false
        modalRatingBar.color = UIColor.black
        modalRatingBar.maxValue = 5
        modalRatingBar.value = 0.0
        
        ////////   slide    ///////////////////
        slidshow.slideshowInterval = 2.0
        slidshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slidshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
        slidshow.pageIndicator = nil

        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        tap.cancelsTouchesInView = false
        
        ////  wesite lable tap add   ///////
        let tapWebsiteLabel: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.websitLabel_Tapped))
        self.website_label.addGestureRecognizer(tapWebsiteLabel)
        
        ////  report location view tap add   ///////
        let tapreportlocationView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.reportlocationView_Tapped))
        self.reportlocationView.addGestureRecognizer(tapreportlocationView)
        
        ////  dogout review view tap add   ///////
        let tapdogoutReviewView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dogoutReviewView_Tapped))
        self.dogoutReviewView.addGestureRecognizer(tapdogoutReviewView)
        
        ////   detail box background tranV tap add   ////////
        let tapdetailBoxTransV: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.detailBoxTransV_Tapped))
        self.detailBoxTransV.addGestureRecognizer(tapdetailBoxTransV)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func websitLabel_Tapped() {
        let url_str = self.website_label.text!
        if (url_str != "No website") {
            if UIApplication.shared.canOpenURL(URL(string: url_str)!) {
                UIApplication.shared.open(URL(string: url_str)!, options: [:], completionHandler: nil)
            } else {
                createAlert(title: "Warning", message: "Cannot open Website")
            }
        }
    }
    
    @objc func reportlocationView_Tapped() {
        self.performSegue(withIdentifier: "hometoreportlocation_segue", sender: self)
    }
    
    @objc func dogoutReviewView_Tapped() {
        
        startActivityIndicator()
        let requestDic = ["token": Global.token, "place": self.place_name, "address": self.address, "page": self.current_display_page] as [String : Any]
        AF.request("http://u900336547.hostingerapp.com/api/get_app_review", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    self.stopActivityIndicator()
                case .success(let responseObject):
                    self.stopActivityIndicator()
                    let responseDict = responseObject as! NSDictionary
//                    print("dogout reviews: \(responseDict)")
                    let status = responseDict["status"] as! String
                    if(status == "success") {
                        if let data = responseDict["data"] as? [String: Any] {
                            self.modalPlaceNameLabel.text = data["place"] as? String
                            self.modalAddressLabel.text = data["address"] as? String
                            let modalRating = data["rating"] as? Double
                            self.modalReviewLabel.text = String(format: "%.1f", modalRating!)
                            self.modalRatingBar.updateValue(with: CGFloat(modalRating!))
                            self.totalReviewsCount = data["total"] as! Int
                            self.modalCountReviewsLabel.text = String(self.totalReviewsCount) + " Dogout reviews"
                            self.is_end = data["is_end"] as! Bool
                            if(self.totalReviewsCount > 0) {
                                let reports = data["reports"] as! [Dictionary<String, AnyObject>]
                                for i in 0..<reports.count {
                                    self.reviews_array.append([reports[i]["user_name"] as! String, String(format:"%.1f", reports[i]["rating"] as! Double), reports[i]["comment"] as! String])
                                }
                            }
                            self.reportsListTableVIew.reloadData()
                            self.dogoutReviewModalTransV.isHidden = false
                            self.dogoutReviewModalView.isHidden = false
                        }
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
    
    @objc func detailBoxTransV_Tapped() {
        animateSideDetailBox(action: "disappear", animated: true)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        GMSPlacesClient.shared().autocompleteQuery(searchText, bounds: nil, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            
            if let results = results {
                self.googleAutoCompletePlaces = results
                self.googleAutoPlacesTableView.reloadData()
//                print(self.googleAutoCompletePlaces)
//                print("\\\\\\\\\\\\\\\\")
            }
        })
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        animateSideDetailBox(action: "disappear", animated: true)
        self.googleAutoPlacesTableView.isHidden = false
        self.checkBoxRegion.isHidden = true
        suggestButtonRegionView.isHidden = true
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.googleAutoPlacesTableView) {
            return self.googleAutoCompletePlaces.count
        } else {
            return self.reviews_array.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == googleAutoPlacesTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "googleplacetableviewcell", for: indexPath) as! GooglePlacesTableViewCell;
            cell.placenameLabel.attributedText = self.googleAutoCompletePlaces[indexPath.row].attributedPrimaryText
            cell.addressLabel.attributedText = self.googleAutoCompletePlaces[indexPath.row].attributedSecondaryText
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reporttableviewcell", for: indexPath) as! ReportsTableViewCell;
            cell.usernameLabel.text = self.reviews_array[indexPath.row][0]
            cell.ratingLabel.text = self.reviews_array[indexPath.row][1] + "/5"
            cell.commentLabel.text = self.reviews_array[indexPath.row][2]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == self.googleAutoPlacesTableView) {
            return 60
        } else {
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == googleAutoPlacesTableView {
            print("ererererer")
            GMSPlacesClient.shared().lookUpPlaceID(self.googleAutoCompletePlaces[indexPath.row].placeID ?? "") { (place, error) in
                if error == nil && place != nil {
                    
                    let autocomplete_selected_latitude = place?.coordinate.latitude ?? 0.0
                    let autocomplete_selected_longitude = place?.coordinate.longitude ?? 0.0
                    let autocomplete_place_id = place?.placeID ?? ""
                    let autocomplete_place_name = place?.name ?? ""
                    
                    let annotation = customAnnotation(title:autocomplete_place_name, subtitle:"", location:CLLocationCoordinate2DMake(autocomplete_selected_latitude, autocomplete_selected_longitude), place_id:autocomplete_place_id, place_description:"");
                    self.googleMapView.addAnnotation(annotation);
//                    if (self.first_place) {
                        let currentLocationCoor:CLLocationCoordinate2D = CLLocationCoordinate2DMake(autocomplete_selected_latitude, autocomplete_selected_longitude);
                        self.googleMapView.setCenter(currentLocationCoor, animated: true);
//                        self.first_place = false;
//                    }
                    self.searchBar.text = autocomplete_place_name
                    self.googleAutoPlacesTableView.isHidden = true
                }
                else {
                    print("Someting went wrong please try again.")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(tableView == self.reportsListTableVIew) {
            if indexPath.section + 1 == tableView.numberOfSections && indexPath.row + 1 == self.reviews_array.count {
                if !self.is_end && self.reach_end {
                    print("rrrrrrrrrrr")
                    self.current_display_page = self.current_display_page + 1
                    startActivityIndicator()
                    let requestDic = ["token": Global.token, "place": self.place_name, "address": self.address, "page": self.current_display_page] as [String : Any]
                    AF.request("http://u900336547.hostingerapp.com/api/get_app_review", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
                        {
                            response in
                            switch response.result {
                            case .failure(let error):
                                print(error)
                                self.stopActivityIndicator()
                            case .success(let responseObject):
                                self.stopActivityIndicator()
                                let responseDict = responseObject as! NSDictionary
                                //                    print("dogout reviews: \(responseDict)")
                                let status = responseDict["status"] as! String
                                if(status == "success") {
                                    if let data = responseDict["data"] as? [String: Any] {
                                        self.is_end = data["is_end"] as! Bool
                                        let reports = data["reports"] as! [Dictionary<String, AnyObject>]
                                        if(reports.count > 0) {
                                            for i in 0..<reports.count {
                                                self.reviews_array.append([reports[i]["user_name"] as! String, String(format:"%.1f", reports[i]["rating"] as! Double), reports[i]["comment"] as! String])
                                            }
                                        }
                                        self.reportsListTableVIew.reloadData()
                                    }
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
                self.reach_end = true
            }
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let height = scrollView.frame.size.height
//        let contentYoffset = scrollView.contentOffset.y
//        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
//        if(distanceFromBottom < height) {
//            if !self.is_end {
//                self.current_display_page = self.current_display_page + 1
//                startActivityIndicator()
//                let requestDic = ["token": Global.token, "place": self.place_name, "address": self.address, "page": self.current_display_page] as [String : Any]
//                AF.request("http://u900336547.hostingerapp.com/api/get_app_review", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
//                    {
//                        response in
//                        switch response.result {
//                        case .failure(let error):
//                            print(error)
//                            self.stopActivityIndicator()
//                        case .success(let responseObject):
//                            self.stopActivityIndicator()
//                            let responseDict = responseObject as! NSDictionary
//                            //                    print("dogout reviews: \(responseDict)")
//                            let status = responseDict["status"] as! String
//                            if(status == "success") {
//                                if let data = responseDict["data"] as? [String: Any] {
//                                    self.is_end = data["is_end"] as! Bool
//                                    let reports = data["reports"] as! [Dictionary<String, AnyObject>]
//                                    if(reports.count > 0) {
//                                        for i in 0..<reports.count {
//                                            self.reviews_array.append([reports[i]["user_name"] as! String, String(format:"%.1f", reports[i]["rating"] as! Double), reports[i]["comment"] as! String])
//                                        }
//                                    }
//                                    self.reportsListTableVIew.reloadData()
//                                }
//                            } else {
//                                let error_type = responseDict["error_type"] as! String
//                                if(error_type == "token_error") {
//                                    self.createAlert(title: "Warning!", message: "Your account is expired. Please sign in again.")
//                                } else if(error_type == "registered") {
//                                    self.createAlert(title: "Warning!", message: "You are already suggest review for this place.")
//                                }
//                            }
//                        }
//                }
//            }
//        }
//    }
    
    @IBAction func disappearButtonAction(_ sender: Any) {
        animateSideDetailBox(action: "disappear", animated: true)
    }
    
    @IBAction func categoryButtonAction(_ sender: Any) {
        if(checkBoxRegion.isHidden) {
            checkBoxRegion.isHidden = false
            categoryButton.setImage(UIImage(named: "cancel"), for: UIControl.State.normal)
            suggestButtonRegionView.isHidden = false
        } else {
            checkBoxRegion.isHidden = true
            categoryButton.setImage(UIImage(named: "plus"), for: UIControl.State.normal)
            suggestButtonRegionView.isHidden = true
        }
        if(!searchBar.isHidden) {
            searchBar.text = ""
            searchBar.isHidden = true
            searchButton.setImage(UIImage(named: "search"), for: UIControl.State.normal)
            self.googleAutoPlacesTableView.isHidden = true
            self.googleAutoCompletePlaces = []
            self.googleAutoPlacesTableView.reloadData()
        }
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        if(searchBar.isHidden) {
            
            searchBar.isHidden = false
            searchButton.setImage(UIImage(named: "left-arrow-black"), for: UIControl.State.normal)
//            self.googleAutoPlacesTableView.isHidden = false
        } else {
            searchBar.text = ""
            searchBar.isHidden = true
            searchButton.setImage(UIImage(named: "search"), for: UIControl.State.normal)
            self.googleAutoPlacesTableView.isHidden = true
            self.googleAutoCompletePlaces = []
            self.googleAutoPlacesTableView.reloadData()
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
    
    @IBAction func websiteButtonAction(_ sender: Any) {
        let url_str = self.website_label.text!
        if UIApplication.shared.canOpenURL(URL(string: url_str)!) {
            UIApplication.shared.open(URL(string: url_str)!, options: [:], completionHandler: nil);
        } else {
            createAlert(title: "Warning", message: "Cannot open Website");
        }
    }
    
    @IBAction func callButtonAction(_ sender: Any) {
//        let new_phonenumber = self.phone_nember.replacingOccurrences(of: " ", with: "")
        let new_phonenumber = self.phone_nember.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let phoneCallURL = URL(string: "tel://+\(new_phonenumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            } else {
                createAlert(title: "Warning!", message: "can not call")
            }
        } else {
            print("no callllllll:  \(self.phone_nember)")
        }
       
    }
    
    @IBAction func writereviewButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "hometowritingreview_segue", sender: self)
    }
    
    @IBAction func suggestnewlocationButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "hometosuggestnewlocation_segue", sender: self)
    }
    
    @IBAction func directionButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "hometodirection_segue", sender: self)
    }
    
    @IBAction func moveCurrentLocationButtonAction(_ sender: Any) {
        let currentLocationCoor:CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        googleMapView.setCenter(currentLocationCoor, animated: true);
    }
    
    @IBAction func signoutButtonAction(_ sender: Any) {
//        signoutAlert(title: "Notice!", message: "Do you really want to sign out?")
        let alert = UIAlertController(title: "Notice!", message:"Do you really want to sign out?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
                self.startActivityIndicator()
                let requestDic = ["token": Global.token] as [String : Any]
                AF.request("http://u900336547.hostingerapp.com/api/logout", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
                    {
                        response in
                        switch response.result {
                        case .failure(let error):
                            print(error)
                            self.stopActivityIndicator()
                        case .success(let responseObject):
                            self.stopActivityIndicator()
                            let responseDict = responseObject as! NSDictionary
                            //                    print("dogout reviews: \(responseDict)")
                            let status = responseDict["status"] as! String
                            if(status == "success") {
                                UserDefaults.standard.set("", forKey: "email")
                                UserDefaults.standard.set("", forKey: "password")
                                self.performSegue(withIdentifier: "hometosignin_segue", sender: self)
                            } else {
                                let error_type = responseDict["error_type"] as! String
                                if(error_type == "token_error") {
                                    self.createAlert(title: "Warning!", message: "Your account is expired. Please sign in again.")
                                }
                            }
                        }
                }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "hometowritingreview_segue") {
            let WritingReviewVC = segue.destination as! WritingReviewViewController
            WritingReviewVC.address = self.address
            WritingReviewVC.place_name = self.place_name
        } else if(segue.identifier == "hometoreportlocation_segue") {
            let ReportLocationVC = segue.destination as! ReportLocationViewController
            ReportLocationVC.address = self.address
            ReportLocationVC.place_name = self.place_name
        } else if(segue.identifier == "hometosuggestnewlocation_segue") {
            let SuggestNewLocationVC = segue.destination as! SuggestNewLocationViewController
//            ReportLocationVC.address = self.address
//            ReportLocationVC.place_name = self.place_name
        } else if(segue.identifier == "hometodirection_segue") {
            let DirectionnVC = segue.destination as! DirectionsViewController
            DirectionnVC.address = self.address
            DirectionnVC.latitude = self.selected_latitude
            DirectionnVC.longitude = self.selected_longitude
        } else if(segue.identifier == "hometosignin_segue") {
            let SigninVC = segue.destination as! SignInViewController
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
        
        self.selected_latitude = String(describing: annotation.coordinate.latitude)
        self.selected_longitude = String(describing: annotation.coordinate.longitude)
        
        var findGoogleAPI = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?"
        findGoogleAPI += "input=" + place_name_kml!
        findGoogleAPI += "&inputtype=textquery"
        findGoogleAPI += "&locationbias=circle:2000@" + String(describing: annotation.coordinate.latitude) + "," + String(describing: annotation.coordinate.longitude)
        findGoogleAPI += "&key=" + map_key
        
        findGoogleAPI = findGoogleAPI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!;
        var url_placeID = URLRequest(url: URL(string: findGoogleAPI)!)
        url_placeID.httpMethod = "GET"
        
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
                        if(result["international_phone_number"] == nil) {
                            self.phone_nember = "No phone number"
                        } else {
                            self.phone_nember = result["international_phone_number"] as! String
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
        var dogout_rating = 0.0
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
        print("place_name:  \(self.place_name)")
        mainName_label.text = place_name
        name_label.text = place_name
        
        address_label.text = address

        phone_label.text = phone_nember
        if phone_nember == "No phone number" {
            callButton.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1.0)
            callButton.setTitle("call not available", for: UIControl.State.normal)
            callButton.titleLabel?.font = UIFont(name: (callButton.titleLabel?.font.fontName)!, size: 12)
            callButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            callButton.isUserInteractionEnabled = false
        } else {
            callButton.backgroundColor = UIColor(red: 255/255, green: 253/255, blue: 93/255, alpha: 1.0)
            callButton.setTitle("call", for: UIControl.State.normal)
            callButton.titleLabel?.font = UIFont(name: (callButton.titleLabel?.font.fontName)!, size: 17)
            callButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            callButton.isUserInteractionEnabled = true
        }

        website_label.text = website
        if website == "No website" {
            websiteButton.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1.0)
            websiteButton.setTitle("website not available", for: UIControl.State.normal)
            websiteButton.titleLabel?.font = UIFont(name: (websiteButton.titleLabel?.font.fontName)!, size: 12)
            websiteButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            websiteButton.isUserInteractionEnabled = false
        } else {
            websiteButton.backgroundColor = UIColor(red: 255/255, green: 253/255, blue: 93/255, alpha: 1.0)
            websiteButton.setTitle("website", for: UIControl.State.normal)
            websiteButton.titleLabel?.font = UIFont(name: (websiteButton.titleLabel?.font.fontName)!, size: 17)
            websiteButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            websiteButton.isUserInteractionEnabled = true
        }
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
        
        /////////  get for dogout reating ////////////
        let requestDic = ["token": Global.token, "place": self.place_name, "address": self.address]
        AF.request("http://u900336547.hostingerapp.com/api/get_app_review", method: .post, parameters: requestDic, encoding: JSONEncoding.default, headers: nil).responseJSON
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
//                        self.douout_ratingBar.updateValue(with: responseDict["data"])
                        let data = responseDict["data"] as? [String: AnyObject]
                        dogout_rating = data?["rating"] as! Double
                        self.douout_ratingBar.updateValue(with: CGFloat(dogout_rating))
                    } else {
                        let error_type = responseDict["error_type"] as! String
//                        if(error_type == "no_user") {
//                            self.createAlert(title: "Warning!", message: "You are not registered. Please create an account.")
//                        } else if(error_type == "no_activated") {
//                            self.createAlert(title: "Warning!", message: "User is not activated. Please check your mail address and password.")
//                        } else if(error_type == "wrong_password") {
//                            self.createAlert(title: "Warning!", message: "Password is incorrect. Please try again.")
//                        }
                    }
                    DispatchQueue.main.async {
                        if self.activityIndicator.isAnimating {
                            self.stopActivityIndicator()
                        }
                        self.animateSideDetailBox(action: "show", animated: true)
                    }
                }
        }
        ////////////////////

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
        var xPosition = 0
        self.detailBoxTransV.isHidden = false
        if action != "show" {
            xPosition = -250
            self.detailBoxTransV.isHidden = true
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
    
    func signoutAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            
        }))
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
    
    //////////// modal action list  //////////////
    @IBAction func modalCloseButtonAction(_ sender: Any) {
        self.dogoutReviewModalTransV.isHidden = true
        self.dogoutReviewModalView.isHidden = true
        self.reviews_array = []
        self.is_end = false
        self.reach_end = false
        self.current_display_page = 1
    }
    
    @IBAction func modalWriteReviewButtonAction(_ sender: Any) {
        self.dogoutReviewModalTransV.isHidden = true
        self.dogoutReviewModalView.isHidden = true
        self.performSegue(withIdentifier: "hometowritingreview_segue", sender: self)
    }
    //////////////////
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


