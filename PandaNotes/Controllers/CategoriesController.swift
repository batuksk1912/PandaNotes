//
//  ViewController.swift
//  PandaNotes
//
//  Created by Baturay Kayatürk on 2019-07-23.
//  Copyright © 2019 Lambton College. All rights reserved.
//

import UIKit

var noteCategory = [NoteCategory]()

class CategoriesController: UITableViewController {
    
    fileprivate let CUSTOM_CELL_ID:String = "CUSTOM_CELL_ID"
    
    fileprivate let header: UIView = {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let label = UILabel(frame: CGRect(x: 18, y: 15, width: 120, height: 20))
        label.text = "NOTE CATEGORIES"
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.textColor = .darkGray
        header.addBorder(toSide: .bottom, withColor: UIColor.lightGray.withAlphaComponent(0.5).cgColor, andThickness: 0.3)
        header.addSubview(label)
        return header
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Categories"
        noteCategory = CoreDataManager.shared.fetchNoteCategories()
        setupTableViewController()
        setupTranslucentViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleAddNewCategory))
        self.navigationItem.setRightBarButtonItems([addButton], animated: false)
        tableView.reloadData()
    }
    
    var textField:UITextField!
    
    @objc fileprivate func handleAddNewCategory() {
        let addAlert = UIAlertController(title: "New Category", message: "Enter a name for this category.", preferredStyle: .alert)
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            addAlert.dismiss(animated: true)
        }))
        
        addAlert.addTextField { (tf) in
            self.textField = tf
        }
        
        addAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            addAlert.dismiss(animated: true)
            guard let title = self.textField.text else { return }
            
            let newFolder = CoreDataManager.shared.createNoteCategory(title: title)
            noteCategory.append(newFolder)
            self.tableView.insertRows(at: [IndexPath(row: noteCategory.count - 1, section: 0)], with: .fade)
        }))
        
        present(addAlert, animated: true)
    }

    
    fileprivate func setupTableViewController() {
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CUSTOM_CELL_ID)
        tableView.tableHeaderView = header
    }
    
    fileprivate func getImage(withColor color: UIColor, andSize size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        return image
    }
    
    fileprivate func setupTranslucentViews() {
        let navigationBar = self.navigationController?.navigationBar
        
        let slightWhite = getImage(withColor: UIColor.white.withAlphaComponent(0.9), andSize: CGSize(width: 30, height: 30))
        
        navigationBar?.setBackgroundImage(slightWhite, for: .default)
        navigationBar?.shadowImage = slightWhite
    }


}

extension CategoriesController {
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            let noteSelectedCategory = noteCategory[indexPath.row]
            if CoreDataManager.shared.deleteNoteCategories(noteCategory: noteSelectedCategory) {
                noteCategory.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: CUSTOM_CELL_ID, for: indexPath) as! CategoryCell
        let categoryForRow = noteCategory[indexPath.row]
        customCell.categoryData = categoryForRow
        return customCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteCategory.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notesController = NotesController()
        let categoryForRowSelected = noteCategory[indexPath.row]
        notesController.categoryData = categoryForRowSelected
        navigationController?.pushViewController(notesController, animated: true)
    }
    
    
}
