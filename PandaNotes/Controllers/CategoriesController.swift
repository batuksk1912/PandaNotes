//
//  ViewController.swift
//  PandaNotes
//
//  Created by Baturay Kayatürk on 2019-07-23.
//  Copyright © 2019 Lambton College. All rights reserved.
//

import UIKit

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
        setupTableViewController()
        setupTranslucentViews()
    }
    
    fileprivate func setupTableViewController() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CUSTOM_CELL_ID)
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: CUSTOM_CELL_ID, for: indexPath)
        customCell.textLabel?.text = "TEST DATA"
        return customCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notesController = NotesController()
        navigationController?.pushViewController(notesController, animated: true)
    }
    
    
}
