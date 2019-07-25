//
//  NotesDetailController.swift
//  PandaNotes
//
//  Created by Baturay Kayatürk on 2019-07-23.
//  Copyright © 2019 Lambton College. All rights reserved.
//

import UIKit

protocol NoteDelegate {
    func saveNewNote(title: String, date: Date, text: String)
}

class NotesDetailController: UIViewController {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let topItems:[UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .camera, target: nil, action: nil)
        ]
        self.navigationItem.setRightBarButtonItems(topItems, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.noteData == nil {
            delegate?.saveNewNote(title: noteTextView.text, date: Date(), text: noteTextView.text)
        } else {
            guard let newText = self.noteTextView.text else { return }
            CoreDataManager.shared.saveUpdatedNote(note: self.noteData, newText: newText)
        }
    }
}
    
