//
//  ButtonFactory.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/15.
//

import UIKit

enum ButtonFactory {
    
    static func makeAuthButton(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        
        button.layer.cornerRadius = 10
        button.setHeight(50)
        
        button.backgroundColor = ThemeColor.blue
            .withAlphaComponent(0.5)
        
        button.setTitle(title, for: .normal)
        
        button.setTitleColor(
            UIColor(white: 1, alpha: 0.64),
            for: .normal
        )
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        return button
    }
    
}
