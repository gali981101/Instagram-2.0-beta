//
//  MessagesVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/27.
//

import UIKit

final class MessagesVC: UITableViewController {
}

// MARK: - Life Cycle

extension MessagesVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
}
