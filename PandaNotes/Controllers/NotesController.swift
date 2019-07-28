//
//  CategoriesNotesController.swift
//  PandaNotes
//
//  Created by Baturay Kayatürk on 2019-07-23.
//  Copyright © 2019 Lambton College. All rights reserved.
//

import UIKit

class NotesController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var categoryData:NoteCategory! {
        didSet {
            notes = CoreDataManager.shared.fetchNotes(from: categoryData)
            filteredNotes = notes
        }
    }
    
    fileprivate var notes = [Note]()
    fileprivate var filteredNotes = [Note]()
    var cachedText:String = ""
    
    fileprivate let CUSTOM_CELL_ID:String = "CUSTOM_CELL_ID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHideKeyboardOnTap()
        self.navigationItem.title = "Notes"
        setupTableViewController()
        setupSearchBar()
    }
    
    fileprivate func setupTableViewController() {
        tableView.register(NoteCell.self, forCellReuseIdentifier: CUSTOM_CELL_ID)
    }
    
    fileprivate func setupSearchBar() {
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
        let topItems:[UIBarButtonItem] = [
            UIBarButtonItem(title: "Sort by Date", style: .done, target: self, action: #selector(self.sortByDate)),
            UIBarButtonItem(title: "Sort by Title", style: .done, target: self, action: #selector(self.sortByTitle))
        ]
        self.navigationItem.setRightBarButtonItems(topItems, animated: true)
        let items: [UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(self.navigateCategories)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "\(notes.count) Notes", style: .done, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.createNewNote))
        ]
        self.toolbarItems = items
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        tableView.reloadData()
    }
    
    @objc fileprivate func sortByDate() {
        notes.sort(by: { (obj1, obj2) -> Bool in
            return obj1.date! < obj2.date!
        })
        filteredNotes.sort(by: { (obj1, obj2) -> Bool in
            return obj1.date! < obj2.date!
        })
        tableView.reloadData()
    }
    
    @objc fileprivate func sortByTitle() {
        notes.sort(by: { (obj1, obj2) -> Bool in
            return obj1.title! < obj2.title!
        })
        filteredNotes.sort(by: { (obj1, obj2) -> Bool in
            return obj1.title! < obj2.title!
        })
        tableView.reloadData()
    }
    
    @objc fileprivate func createNewNote() {
        let noteDetailController = NotesDetailController()
        noteDetailController.delegate = (self as NoteDelegate)
        navigationController?.pushViewController(noteDetailController, animated: true)
    }
    
    @objc fileprivate func navigateCategories() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension NotesController {
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let alert = UIAlertController(title: "Notice", message: "Do you want to remove the note?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
                let targetRow = indexPath.row
                if CoreDataManager.shared.deleteNote(note: self.notes[targetRow]) {
                    self.notes.remove(at: targetRow)
                    self.filteredNotes.remove(at: targetRow)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.viewWillAppear(true)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        actions.append(deleteAction)
        return actions
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: CUSTOM_CELL_ID, for: indexPath) as! NoteCell
        let noteForRow = self.filteredNotes[indexPath.row]
        customCell.noteData = noteForRow
        return customCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredNotes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notesDetailController = NotesDetailController()
        let noteForRow = self.filteredNotes[indexPath.row]
        notesDetailController.noteData = noteForRow
        navigationController?.pushViewController(notesDetailController, animated: true)
    }
}

extension NotesController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotes = notes.filter({ (note) -> Bool in
            return note.title?.lowercased().contains(searchText.lowercased()) ?? false
        })
        if searchBar.text!.isEmpty && filteredNotes.isEmpty {
            filteredNotes = notes
        }
        cachedText = searchText
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if !cachedText.isEmpty && !filteredNotes.isEmpty {
            searchController.searchBar.text = cachedText
        }
    }
}

extension NotesController: NoteDelegate {
    func saveNewNote(title: NSData, date: Date, text: NSData, lat: Double, lng: Double) {
        let newNote = CoreDataManager.shared.createNewNote(title: title, date: date, text: text, lat: lat, lng: lng, noteCategory: self.categoryData)
        notes.append(newNote)
        filteredNotes.append(newNote)
        self.tableView.insertRows(at: [IndexPath(row: notes.count - 1, section: 0)], with: .fade)
    }
}



