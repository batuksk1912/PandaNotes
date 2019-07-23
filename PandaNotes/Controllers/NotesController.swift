//
//  CategoriesNotesController.swift
//  PandaNotes
//
//  Created by Baturay Kayatürk on 2019-07-23.
//  Copyright © 2019 Lambton College. All rights reserved.
//

import UIKit

class NotesController: UITableViewController {
    
    fileprivate let CUSTOM_CELL_ID:String = "CUSTOM_CELL_ID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Notes"
        setupTableViewController()
    }
    
    fileprivate func setupTableViewController() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CUSTOM_CELL_ID)
    }
    
    
}

extension NotesController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: CUSTOM_CELL_ID, for: indexPath)
        customCell.textLabel?.text = "TEST NOTE DATA"
        return customCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}



