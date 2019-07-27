//
//  LocationController.swift
//  PandaNotes
//
//  Created by Baturay Kayatürk on 2019-07-26.
//  Copyright © 2019 Lambton College. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    fileprivate let locManager = CLLocationManager()
    fileprivate var curLoc = CLLocation()
    fileprivate let mapView = MKMapView()
    fileprivate var location2D = CLLocationCoordinate2D()

    var lat:Double?
    var lng:Double?
    
    fileprivate func setupMapKit() {
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true        
        mapView.center = view.center
        view.addSubview(mapView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupMapKit()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.distanceFilter = 100
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    func addPin() {
        location2D = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = location2D
        myAnnotation.title = "Note captured at this location."
        self.mapView.addAnnotation(myAnnotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addPin()
        locManager.stopUpdatingLocation()
        let zoomArea = MKCoordinateRegion(center: location2D, span: MKCoordinateSpan (latitudeDelta: 0.5, longitudeDelta: 0.5))
        self.mapView.setRegion(zoomArea, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locManager.stopUpdatingLocation()
    }
}
