//
//  MapViewController.swift
//  Assignment1_Maps
//
//  Created by Xcode User on 2020-10-09.
//  Copyright © 2020 Bhavik Jain. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, UITextFieldDelegate,MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource {

    let locationManager = CLLocationManager()
    let initialLocation = CLLocation(latitude: 43.8430, longitude: -79.5395)
    
    
    @IBOutlet var myMapView : MKMapView!
    @IBOutlet var tbLocEntered : UITextField!
    @IBOutlet var myTableView : UITableView!
    @IBOutlet var segmentDecision : UISegmentedControl!
    @IBOutlet var tbWaypoint1 : UITextField!
    @IBOutlet var tbWaypoint2 : UITextField!
    
    
    var routeSteps = ["Enter a destination to see the steps"]
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
  

    let regionRadius : CLLocationDistance = 1000
    func centerMapOnLocation(location : CLLocation){
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: regionRadius * 2.0,longitudinalMeters: regionRadius*2.0)
        
        if (location.coordinate.latitude == initialLocation.coordinate.latitude && location.coordinate.longitude == initialLocation.coordinate.longitude){
            let circle = MKCircle(center: location.coordinate, radius: regionRadius * 15.0)
            myMapView.addOverlay(circle)
            
        }
        myMapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbLocEntered.isEnabled = true
        tbWaypoint1.isEnabled = true
        tbWaypoint2.isEnabled = false
        
        centerMapOnLocation(location: initialLocation)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = initialLocation.coordinate
        dropPin.title = "Starting at Canada's Wonderland!"
        self.myMapView.addAnnotation(dropPin)
        self.myMapView.selectAnnotation(dropPin, animated: true)
    }

    func findDirectionWaypoint(){
        var newLocation : CLLocation = CLLocation()
        let waypoint = tbWaypoint1.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(waypoint!, completionHandler:
            {(placemarks,error) -> Void in
                if(error != nil){
                    print("Error",error ?? "ERROR")
                }
                if let placemark = placemarks?.first{
                    let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
                    
                    newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                   
                    self.centerMapOnLocation(location: newLocation)
                    
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = coordinates
                    dropPin.title = placemark.name
                    self.myMapView.addAnnotation(dropPin)
                    self.myMapView.selectAnnotation(dropPin, animated: true)
                    
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.initialLocation.coordinate, addressDictionary: nil))
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: newLocation.coordinate, addressDictionary: nil))
                    
                    request.requestsAlternateRoutes = false
                    request.transportType = .automobile
                    
                    
                    let directions = MKDirections(request: request)
                    directions.calculate(completionHandler:
                        {[unowned self] response,error in
                            
                            for route in (response?.routes)!{
                                self.myMapView.addOverlay(route.polyline, level:MKOverlayLevel.aboveRoads)
                                self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                //self.routeSteps.removeAll()
                                self.routeSteps.append("")
                                self.routeSteps.append("Route to Waypoint 1")
                                print("Route to Waypoint1...")
                                for step in route.steps {
                                    self.routeSteps.append(step.instructions)
                                    print(self.routeSteps)
                                }
                                if (self.segmentDecision.selectedSegmentIndex == 1){
                                    _ = self.findDirectionToWaypoint2ViaWaypoint1(waypoint1Location: newLocation)
                                }
                                else{
                                
                                _=self.findDestinationafterWaypoint(newLocation1: newLocation)
                                }
                                
                                self.myTableView.reloadData()
                                
                            }
                        }
                        
                    )
                }
                
        }
            
        )
       
        
        
    }
    
    func findDirectionToWaypoint2ViaWaypoint1(waypoint1Location : CLLocation) -> CLLocation{
        var waypoint2Location : CLLocation = CLLocation()
        let waypoint2 = tbWaypoint2.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(waypoint2!, completionHandler:
            {(placemarks,error) -> Void in
                if(error != nil){
                    print("Error",error ?? "ERROR")
                }
                if let placemark = placemarks?.first{
                    let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
                    
                    waypoint2Location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    
                    
                    
                    self.centerMapOnLocation(location: waypoint1Location)
                    
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = coordinates
                    dropPin.title = placemark.name
                    self.myMapView.addAnnotation(dropPin)
                    self.myMapView.selectAnnotation(dropPin, animated: true)
                    
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: waypoint1Location.coordinate, addressDictionary: nil))
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: waypoint2Location.coordinate, addressDictionary: nil))
                    
                    request.requestsAlternateRoutes = false
                    request.transportType = .automobile
                    
                    
                    
                    let directions = MKDirections(request: request)
                    directions.calculate(completionHandler:
                        {[unowned self] response,error in
                            
                            for route in (response?.routes)!{
                                self.myMapView.addOverlay(route.polyline, level:MKOverlayLevel.aboveRoads)
                                self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                
                                //self.routeSteps.removeAll()
                                self.routeSteps.append("")
                                self.routeSteps.append("Route to Waypoint 2")
                                print("Route to Waypoint 2.........")
                                for step in route.steps {
                                    self.routeSteps.append(step.instructions)
                                    print(self.routeSteps)
                                }
                                self.findDestinationafterWaypoint(newLocation1: waypoint2Location)
                                
                                self.myTableView.reloadData()
                            }
                        }
                    )
                }
        }
        )
        return waypoint2Location
        
    }
    
    
    
    
    func findDestinationafterWaypoint(newLocation1:CLLocation) -> CLLocation{
        var newLocation2 : CLLocation = CLLocation()
        let dest = tbLocEntered.text
        let geocoder1 = CLGeocoder()
        geocoder1.geocodeAddressString(dest!, completionHandler:
            {(placemarks,error) -> Void in
                if(error != nil){
                    print("Error",error ?? "ERROR")
                }
                if let placemark = placemarks?.first{
                    let coordinates1 : CLLocationCoordinate2D = placemark.location!.coordinate
                    
                    newLocation2 = CLLocation(latitude: coordinates1.latitude, longitude: coordinates1.longitude)
                    
                    self.centerMapOnLocation(location: newLocation2)
                    let initLocation = CLLocation(latitude: self.initialLocation.coordinate.latitude, longitude: self.initialLocation.coordinate.longitude)
                    let distance = initLocation.distance(from: newLocation2)
                    if distance > (self.regionRadius * 15.0){
                        let alert = UIAlertController(title: "Confirmation", message: "Your entered location is not in the BOUNDING BOX!!", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "Confirmation", message: "Your entered location is in the BOUNDING BOX!!", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = coordinates1
                    dropPin.title = placemark.name
                    self.myMapView.addAnnotation(dropPin)
                    self.myMapView.selectAnnotation(dropPin, animated: true)
                    
                    let request1 = MKDirections.Request()
                    request1.source = MKMapItem(placemark: MKPlacemark(coordinate: newLocation1.coordinate, addressDictionary: nil))
                    request1.destination = MKMapItem(placemark: MKPlacemark(coordinate: newLocation2.coordinate, addressDictionary: nil))
                    
                    request1.requestsAlternateRoutes = false
                    request1.transportType = .automobile
                    
                    
                    let directions1 = MKDirections(request: request1)
                    
                    
                    directions1.calculate(completionHandler:
                        {[unowned self] response,error in
                            
                            
                            if response != nil{
                                for route in (response?.routes)!{
                                    self.myMapView.addOverlay(route.polyline, level:MKOverlayLevel.aboveRoads)
                                    self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                    
                                   // self.routeSteps.removeAll()
                                    self.routeSteps.append("")
                                    self.routeSteps.append("Route to Final Location....")
                                    print("Route to Final Destination...")
                                    for step in route.steps {
                                        self.routeSteps.append(step.instructions)
                                        print(self.routeSteps)
                                    }
                                    self.myTableView.reloadData()
                                }
                            }else{
                                print("Could not find location....")
                            }
                        }
                        
                    )
                    
                }
        }
        )
        return newLocation2
    }
    
    
    func findDestination(){
        var newLocation : CLLocation = CLLocation()
        let locationText = tbLocEntered.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationText!, completionHandler:
            {(placemarks,error) -> Void in
                if(error != nil){
                    print("Error",error ?? "ERROR")
                }
                if let placemark = placemarks?.first{
                    let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
                    
                    let initLocation = CLLocation(latitude: self.initialLocation.coordinate.latitude, longitude: self.initialLocation.coordinate.longitude)
                    
                    
                     newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    
                    let distance = initLocation.distance(from: newLocation)
                   
                    if distance > (self.regionRadius * 15.0){
                        let alert = UIAlertController(title: "Confirmation", message: "Your entered location is not in the BOUNDING BOX!!", preferredStyle: UIAlertController.Style.alert)
                         alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                          self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "Confirmation", message: "Your entered location is in the BOUNDING BOX!!", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    
                    self.centerMapOnLocation(location: newLocation)
                    
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = coordinates
                    dropPin.title = placemark.name
                    self.myMapView.addAnnotation(dropPin)
                    self.myMapView.selectAnnotation(dropPin, animated: true)
                    
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.initialLocation.coordinate, addressDictionary: nil))
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
                    
                    request.requestsAlternateRoutes = false
                    request.transportType = .automobile
                    
                    
                    
                    let directions = MKDirections(request: request)
                    directions.calculate(completionHandler:
                        {[unowned self] response,error in
                            
                            for route in (response?.routes)!{
                                self.myMapView.addOverlay(route.polyline, level:MKOverlayLevel.aboveRoads)
                                self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                
                              //  self.routeSteps.removeAll()
                                self.routeSteps.append("")
                                self.routeSteps.append("Route To Destination:")
                                for step in route.steps {
                                    self.routeSteps.append(step.instructions)
                                }
                                self.myTableView.reloadData()
                            }
                        }
                    )
                }
        }
        )
    }
    
    func toRemoveOverlayAnnotations(){
        if let overlays = self.myMapView?.overlays {
            for overlay in overlays {
                if overlay is MKPolyline {
                    self.myMapView.removeOverlays(self.myMapView.overlays)
                }
            }
        }
        self.myMapView.removeAnnotations(self.myMapView.annotations)
        self.centerMapOnLocation(location: initialLocation)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = initialLocation.coordinate
        dropPin.title = "Starting at Canada's Wonderland!"
        self.myMapView.addAnnotation(dropPin)
        self.myMapView.selectAnnotation(dropPin, animated: true)
    }
   
    @IBAction func checkSegmentInput(sender:UISegmentedControl){
        if(segmentDecision.selectedSegmentIndex == 0){
            tbLocEntered.isEnabled = true
            tbWaypoint1.isEnabled = true
            tbWaypoint2.isEnabled = false
            toRemoveOverlayAnnotations()
            tbWaypoint2.text = ""
           
        }
        if(segmentDecision.selectedSegmentIndex == 1){
            tbLocEntered.isEnabled = true
            tbWaypoint1.isEnabled = true
            tbWaypoint2.isEnabled = true
            toRemoveOverlayAnnotations()
        }
        if(segmentDecision.selectedSegmentIndex == 2){
            tbLocEntered.isEnabled = true
            tbWaypoint1.isEnabled = false
            tbWaypoint2.isEnabled = false
            toRemoveOverlayAnnotations()
            tbWaypoint2.text=""
            tbWaypoint1.text=""
        }
    }
    
    @IBAction func findNewLocation(){
        if let overlays = self.myMapView?.overlays {
            for overlay in overlays {
                if overlay is MKPolyline {
                    self.myMapView.removeOverlays(self.myMapView.overlays)
                }
            }
        }
        self.routeSteps.removeAll()
        if self.segmentDecision.selectedSegmentIndex == 2{
            findDestination()
        }
        if self.segmentDecision.selectedSegmentIndex == 0{
           
            findDirectionWaypoint()
        }
        if self.segmentDecision.selectedSegmentIndex == 1{
           
            findDirectionWaypoint()
        }
        
    
}
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKCircle{
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        }
        
        if overlay is MKPolyline{
            let renderer = MKPolylineRenderer(polyline : overlay as! MKPolyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3.0
            return renderer
        }
        return MKOverlayRenderer()
}

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSteps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tablecell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        
        tablecell.textLabel?.text = routeSteps[indexPath.row]
        return tablecell
    }
    

}
