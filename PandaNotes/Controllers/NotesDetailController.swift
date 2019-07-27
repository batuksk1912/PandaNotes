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
    func saveNewNote(title: NSData, date: Date, text: NSData, lat: Double, lng: Double)
}

class NotesDetailController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
        return dateFormatter
    }()
    
    var noteData:Note! {
        didSet {
            noteTextView.attributedText = noteData.text?.toAttributedString()
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
        self.setupHideKeyboardOnTap()
        view.backgroundColor = .white
        setupTextView()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.distanceFilter = 20
        locManager.requestWhenInUseAuthorization()
        let topItems:[UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.checkLocation)),
            UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(self.imageAdder))
        ]
        self.navigationItem.setRightBarButtonItems(topItems, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        curLoc = locManager.location!
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways) {
            lat = curLoc.coordinate.latitude
            lng = curLoc.coordinate.longitude
        }
    }
    
    @objc fileprivate func checkLocation() {
        if (self.noteData != nil) {
        let locationController = LocationController()
        print(noteData.lat.rounded(digits: 3))
        print(lat!.rounded(digits: 3))
        if (noteData.lat != 0.0 && noteData.lng != 0.0) {
        locationController.lat = noteData.lat.rounded(digits: 3)
        locationController.lng = noteData.lng.rounded(digits: 3)
        } else {
            locationController.lat = lat?.rounded(digits: 3)
            locationController.lng = lng?.rounded(digits: 3)
        }
        navigationController?.pushViewController(locationController, animated: true)
        }
    }
    
    @objc fileprivate func imageAdder() {
        if (self.noteData != nil) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self;
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add an Image", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: false)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //let attachment = NSTextAttachment()
            //attachment.image = image
            //calculate new size.  (-20 because I want to have a litle space on the right of picture)
            //let newImageWidth = (noteTextView.bounds.size.width - 20 )
            //let scale = newImageWidth/image.size.width
            //let newImageHeight = image.size.height * scale
            //resize this
            //attachment.bounds = CGRect.init(x: 0, y: 0, width: newImageWidth, height: newImageHeight)
            //put your NSTextAttachment into and attributedString
            let scaledImage = image.resized(toWidth: self.noteTextView.frame.size.width)
            let encodedImageString = (scaledImage!.pngData()?.base64EncodedString())!
            let attString = NSAttributedString(base64EndodedImageString: encodedImageString)!
            //add this attributed string to the current position.
            noteTextView.textStorage.insert(attString, at: noteTextView.selectedRange.location)
            picker.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        } else {
            print("Error!")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.noteData == nil {
            if (self.noteTextView.text != "") {
                delegate?.saveNewNote(title: noteTextView.attributedText.toNSData()!, date: Date(), text: noteTextView.attributedText.toNSData()!, lat:lat!.rounded(digits: 3), lng:lng!.rounded(digits: 3))
            }
        } else {
                //lat = 43.80
                if (noteData.lat.rounded(digits: 3) != lat?.rounded(digits: 3) || noteData.lng.rounded(digits: 3) != lng?.rounded(digits: 3) ) {
                    let alert = UIAlertController(title: "Notice", message: "Note location is changed. Do you want to update location?", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
                        guard let newText = self.noteTextView.attributedText.toNSData() else { return }
                        CoreDataManager.shared.saveUpdatedNote(note: self.noteData, newText: newText, newLat: self.lat!.rounded(digits: 3), newLng: self.lng!.rounded(digits: 3))
                        self.navigationController?.popViewController(animated: false)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true)
                    })
                }
             else {
                guard let newText = self.noteTextView.attributedText.toNSData() else { return }
                CoreDataManager.shared.saveUpdatedNote(note: self.noteData, newText: newText, newLat: noteData.lat.rounded(digits: 3), newLng: noteData.lng.rounded(digits: 3))
            }
        }
    }
}
    
