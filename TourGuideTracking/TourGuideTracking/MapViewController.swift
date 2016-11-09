//
//  MapViewController.swift
//  TourGuideTracking
//
//  Created by Quoc Huy Ngo on 10/14/16.
//  Copyright © 2016 Quoc Huy Ngo. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import SwiftR

class MapViewController: UIViewController {


    @IBOutlet weak var ivTest1: UIImageView!
    @IBOutlet weak var displaySegmented: UISegmentedControl!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var vWarning: UIView!
    
    @IBOutlet weak var tvWarning: UITextView!
    
    @IBOutlet weak var btnSendWarning: UIButton!
    @IBOutlet weak var consTopVWarning: NSLayoutConstraint!
    
    @IBOutlet weak var consBottomInformWarningOption: NSLayoutConstraint!
    @IBOutlet weak var vBackgroundWarning: UIView!
    

   

    var tour:Tour!
    var markerSelected:Any!
    var chatHub: Hub?
    var connection: SignalR?
    
    var locationManager:CLLocationManager = CLLocationManager();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        let tabBar = (self.tabBarController as! CustomTabBarController)
        tabBar.currentTour = tour
        connectServer()
        //displaySegmented.selectedSegmentIndex = 0
        self.mapView.delegate = self
        
        InitView()

        
        getPlacesLocation()
        
        
    }
  
    func InitView()
    {
        tvWarning.layer.borderColor = UIColor.lightGray.cgColor
        tvWarning.layer.borderWidth = 0.5
        tvWarning.layer.cornerRadius = 5
        tvWarning.layer.masksToBounds = true
    }
    
    @IBAction func displayLocationSegmentedValueChanged(_ sender: AnyObject) {
        if displaySegmented.selectedSegmentIndex == 0{
            if (Singleton.sharedInstance.places?.count == 0){
                getPlacesLocation()
            }
            else{
                displayPlacesOnMap()
            }
        }
        else{
            if Singleton.sharedInstance.tourists?.count == 0{
                getTouristsLocation()
            }
            else{
                displayTouristOnMap()
            }
        }
    }
    

    
    //get tour location
    func getPlacesLocation(){
        let url = URLs.makeURL_EXTEND(url: URLs.URL_GET_TOURS, extend: URL_EXTEND.PLACES, param: tour.tourId!)
        NetworkService<Place>.makeGetRequest(URL: url){
            response, error in
            if error == nil{
                let message = response?.message
                if message == nil{
                    let places = response?.listData
                    Singleton.sharedInstance.places = places
                    self.displayPlacesOnMap()
                }
                else{
                    Alert.showAlertMessage(userMessage: message!, vc: self)
                }
            }
            else {
                Alert.showAlertMessage(userMessage: ERROR_MESSAGE.CONNECT_SERVER , vc: self)
            }
        }
    }
    
    func getTouristsLocation(){
        let url = URLs.makeURL_EXTEND(url: URLs.URL_GET_TOURS, extend: URL_EXTEND.TOURISTS_LOCATION, param: tour.tourId!)
        NetworkService<Tourist>.makeGetRequest(URL: url){
            response, error in
            if error == nil{
                let message = response?.message
                if message == nil{
                    let tourists = response?.listData
                    Singleton.sharedInstance.tourists = tourists
                    self.displayTouristOnMap()
                    self.updateLocation(latitude: (tourists?[0].location?.latitude)!, longitude: (tourists?[0].location?.longitude)!)
                }
                else{
                    Alert.showAlertMessage(userMessage: message!, vc: self)
                }
            }
            else{
                Alert.showAlertMessage(userMessage: ERROR_MESSAGE.CONNECT_SERVER, vc: self)
            }
        }
    }
    
    func displayPlacesOnMap(){
        let places = Singleton.sharedInstance.places
         self.setMapView(lat: (places?[0].location?.latitude!)!, long: (places?[0].location?.longitude!)!)
        for place in places!{
            creteMarker(latitude: place.location.latitude!, longitude: place.location.longitude!, data:place, isTourist: false).map = mapView
        }

    }
    
    func displayTouristOnMap(){
        let tourists = Singleton.sharedInstance.tourists
        self.setMapView(lat: (tourists?[0].location?.latitude!)!, long: (tourists?[0].location?.longitude!)!)
        for tourist in tourists!{
            creteMarker(latitude: tourist.location!.latitude!, longitude: tourist.location!.longitude!, data:tourist, isTourist: true).map = mapView
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.displaySegmented.selectedSegmentIndex == 0{
            let placeDetailsVC = segue.destination as! PlaceDetailsViewController
            placeDetailsVC.place = markerSelected as! Place
        }
    }
    
    func connectServer(){
        SwiftR.useWKWebView = false
    
        SwiftR.signalRVersion = .v2_2_0
        
        connection = SwiftR.connect("http://192.168.0.104:3407/signalr/hubs") { [weak self] connection in
            connection.queryString = ["MANAGER_ID" : "1", "USER_ID" : "TOURGUIDE_1"]
            self?.chatHub = connection.createHubProxy("hubServer")
           
            self?.chatHub?.on("broadcastMessage") { args in
                
                }
            }
        connection?.starting = { [weak self] in
            //self?.statusLabel.text = "Starting..."
            //self?.startButton.isEnabled = false
            //self?.sendButton.isEnabled = false
        }
        
        connection?.reconnecting = { [weak self] in
            //self?.statusLabel.text = "Reconnecting..."
            //self?.startButton.isEnabled = false
            //self?.sendButton.isEnabled = false
        }
        
        connection?.connected = { [weak self] in
            print("Connection ID: \(self?.connection?.connectionID!)")
            //self?.statusLabel.text = "Connected"
            //self?.startButton.isEnabled = true
            //self?.startButton.title = "Stop"
            //self?.sendButton.isEnabled = true
        }
        
        connection?.error = { error in
            print("Error connect1: \(error)")
            
            // Here's an example of how to automatically reconnect after a timeout.
            //
            // For example, on the device, if the app is in the background long enough
            // for the SignalR connection to time out, you'll get disconnected/error
            // notifications when the app becomes active again.
            
            if let source = error?["source"] as? String, source == "TimeoutException" {
                print("Connection timed out. Restarting...")
                self.connection?.start()
            }
        }

    }
    
    func updateLocation(latitude:Double, longitude:Double){
            chatHub?.invoke("updateLocation", arguments: [latitude, longitude])
    }
    
    
    // MARK Popup warning
    
    @IBAction func closeWarningPopup(_ sender: Any) {
        HiddenWarningPopup()
        
    }
    
    @IBAction func sendWarningForTourist(_ sender: Any) {
        
        HiddenInformWarningOption()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.ShowWarningPopup()
        })
        
        
    }
    
    func ShowWarningPopup() {
        
        vBackgroundWarning.isHidden = false
        UIView.animate(withDuration: 0.5, animations:
            {
                //self.vWarning.isHidden = false
                self.consTopVWarning.constant = 100
                self.view.layoutIfNeeded();
        })
    }
    
    func HiddenWarningPopup() {
        
        UIView.animate(withDuration: 0.5, animations:
            {
                self.consTopVWarning.constant = -300
                self.view.layoutIfNeeded();
        }, completion: { finished in
                self.vBackgroundWarning.isHidden = true
        })
        
        view.endEditing(true)
        
    }
    
    // MARK Inform Warning Option
    
    @IBAction func informWarningOption(_ sender: Any) {
        
        HiddenWarningPopup()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.ShowInformWarningOption()
        })
        
    }
    
    func ShowInformWarningOption() {
        
        
        UIView.animate(withDuration: 0.3, animations:
            {
                
                self.consBottomInformWarningOption.constant = 0
                self.view.layoutIfNeeded();
        })
        vBackgroundWarning.isHidden = false
    }
    
    func HiddenInformWarningOption() {
        
        
        UIView.animate(withDuration: 0.3, animations:
            {
                self.consBottomInformWarningOption.constant = -208
                self.view.layoutIfNeeded();

        }, completion: { finished in
                self.vBackgroundWarning.isHidden = true
        })
    }
    
    @IBAction func closeAllPopup(_ sender: Any) {
        HiddenInformWarningOption()
    }
    
}

extension MapViewController: GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
       // mapView.selectedMarker = marker
        var customInfoWindow:Any!
        if self.displaySegmented.selectedSegmentIndex == 0{
            
            let data = marker.userData as! Place
            self.markerSelected = data
            
            customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as!  CustomInfoWindow
            (customInfoWindow as! CustomInfoWindow).place = data
            
//            var positionMarker = mapView.projection.point(for: marker.position)
//            
//            let newPositionMarker = CGPoint(x: positionMarker.x, y: positionMarker.y - 100)
//            
//            let camera = GMSCameraUpdate.setTarget(mapView.projection.coordinate(for: newPositionMarker))
//            
//            mapView.animate(with: camera)
            
           
        }
        else{
            let data = marker.userData as! Tourist
            self.markerSelected = data
            customInfoWindow = Bundle.main.loadNibNamed("TouristInfoWindow", owner: self, options: nil)?[0] as!  TouristInfoWindow
            (customInfoWindow as! TouristInfoWindow).tourist = data

        }
        
        return customInfoWindow as! UIView?
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Tap marker")
        return false
    }
    
    
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if self.displaySegmented.selectedSegmentIndex == 0{
            self.performSegue(withIdentifier: "SeguePlaceDetails", sender: self)
        }
    }
    func setMapView(lat:Double = 0, long:Double = 0) {
        mapView.clear()
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 12.0)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
    }
    
    func creteMarker(latitude:Double, longitude:Double, data:AnyObject?, isTourist: Bool) -> GMSMarker{
        // Creates a marker in the center of the map.
        
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.userData = data
        
        if isTourist{
            
            let ivmarker = UIImage(named: "2")
            let ivAvatar = UIImage(named: "ic_avatar")
            
            drawMarker(marker: marker, image: ivAvatar!, markerImage: ivmarker!)
            
            
        }else{
            
            let ivmarker = UIImage(named: "3")
            let ivAvatar = UIImage(named: "ic_avatar")
            
            drawMarker(marker: marker, image: ivAvatar!, markerImage: ivmarker!)
        }
        
        return marker
    }
    
    func drawMarker(marker: GMSMarker ,image: UIImage, markerImage: UIImage ) {
        
        let markerWidth  = 64
        let markerHeight = 76
        
        let imageWith = 58
        let topSpace = 3
        
        if(image == nil && markerImage == nil)
        {
            return
        }
        
        let vTemp = UIView(frame: CGRect(x: 0, y: 0, width: markerWidth, height: markerHeight))
        vTemp.backgroundColor = UIColor.clear
        
        let ivMarker = UIImageView(frame: CGRect(x: 0, y: 0, width: markerWidth, height: markerHeight))
        ivMarker.backgroundColor = UIColor.clear
        
        
        
        let ivPhoto = UIImageView(frame: CGRect(x: topSpace, y: topSpace, width: imageWith, height: imageWith))
        ivPhoto.backgroundColor = UIColor.clear
        ivPhoto.contentMode = UIViewContentMode.scaleAspectFill
        ivPhoto.clipsToBounds = true
        ivPhoto.layer.cornerRadius = ivPhoto.frame.size.width / 2
        ivPhoto.layer.masksToBounds = true
        
        
        vTemp.addSubview(ivPhoto)
        vTemp.addSubview(ivMarker)
        
        ivMarker.image = markerImage
        ivPhoto.image = image
        
        //vTest = vTemp
        
        
        UIGraphicsBeginImageContextWithOptions(vTemp.bounds.size, false, image.scale)
        vTemp.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

        
        marker.icon = finalImage
        
        
    }
    
}




extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let hub = chatHub, {
//            hub.invoke("updateLocation", arguments: ["37.121300", "-95.416603"])
//        }
        updateLocation(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude);
    }
}
