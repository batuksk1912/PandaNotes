//
//  NotesDetailController.swift
//  PandaNotes
//
//  Created by Baturay Kayatürk on 2019-07-23.
//  Copyright © 2019 Lambton College. All rights reserved.
//

import UIKit
import CoreLocation

protocol NoteDelegate {
    func saveNewNote(title: String, date: Date, text: String, lat: Double, lng: Double)
}

class NotesDetailController: UIViewController, CLLocationManagerDelegate {
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
        return dateFormatter
    }()
    
    var noteData:Note! {
        didSet {
            noteTextView.text = noteData.title
            dateTimeLabel.text = dateFormatter.string(from: noteData.date ?? Date())
        }
    }
    
    var delegate: NoteDelegate?
    fileprivate let locManager = CLLocationManager()
    fileprivate var curLoc = CLLocation()
    fileprivate var lat:Double?
    fileprivate var lng:Double?
    
    fileprivate var noteTextView: UITextView = {
        let nt = UITextView()
        nt.translatesAutoresizingMaskIntoConstraints = false
        nt.text = ""
        nt.isEditable = true
        nt.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return nt
    }()
    
    fileprivate lazy var dateTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .gray
        label.text = dateFormatter.string(from: Date())
        label.textAlignment = .center
        return label
    }()
    
    fileprivate func setupTextView() {
        view.addSubview(dateTimeLabel)
        view.addSubview(noteTextView)
        
        dateTimeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 90).isActive = true
        dateTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        dateTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        noteTextView.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor).isActive = true
        noteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        noteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        noteTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTextView()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.distanceFilter = 100
        locManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        curLoc = locManager.location!
        let topItems:[UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.checkLocation)),
            UIBarButtonItem(barButtonSystemItem: .camera, target: nil, action: nil)
        ]
        self.navigationItem.setRightBarButtonItems(topItems, animated: false)
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways) {
            lat = curLoc.coordinate.latitude
            lng = curLoc.coordinate.longitude
        }
    }
    
    @objc fileprivate func checkLocation() {
        let locationController = LocationController()
        if (noteData.lat != 0.0 && noteData.lng != 0.0) {
        locationController.lat = noteData.lat.rounded(digits: 2)
        locationController.lng = noteData.lng.rounded(digits: 2)
        } else {
            locationController.lat = lat?.rounded(digits: 2)
            locationController.lng = lng?.rounded(digits: 2)
        }
        navigationController?.pushViewController(locationController, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.noteData == nil {
            if (self.noteTextView.text != "") {
                delegate?.saveNewNote(title: noteTextView.text, date: Date(), text: noteTextView.text, lat:lat!.rounded(digits: 2), lng:lng!.rounded(digits: 2))
            }
        } else {
            if (noteData.lat.rounded(digits: 2) != lat?.rounded(digits: 2) || noteData.lng.rounded(digits: 2) != lng?.rounded(digits: 2) ) {
                let alert = UIAlertController(title: "Notice", message: "Note location is changed. Do you want to update location?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
                    guard let newText = self.noteTextView.text else { return }
                    CoreDataManager.shared.saveUpdatedNote(note: self.noteData, newText: newText, newLat: self.lat!.rounded(digits: 2), newLng: self.lng!.rounded(digits: 2))
                    self.navigationController?.popViewController(animated: false)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
            guard let newText = self.noteTextView.text else { return }
            CoreDataManager.shared.saveUpdatedNote(note: self.noteData, newText: newText, newLat: noteData.lat.rounded(digits: 2), newLng: noteData.lng.rounded(digits: 2))
            }
        }
    }
}
    
