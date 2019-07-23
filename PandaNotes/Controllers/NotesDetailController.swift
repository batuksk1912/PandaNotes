//
//  NotesDetailController.swift
//  PandaNotes
//
//  Created by Baturay Kayatürk on 2019-07-23.
//  Copyright © 2019 Lambton College. All rights reserved.
//

import UIKit

class NotesDetailController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let topItems:[UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .camera, target: nil, action: nil)
        ]
        self.navigationItem.setRightBarButtonItems(topItems, animated: false)
    }
}
    
