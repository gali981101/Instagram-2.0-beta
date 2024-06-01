//
//  AlertFactory.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/17.
//

import UIKit

enum AlertFactory {
    
    static func makeSignUpErrorAlert(title: String = K.AlertTitle.signUpError, message: String) -> UIAlertController {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: K.ActionText.ok, style: .cancel)
        
        alert.addAction(okAction)
        
        return alert
    }
    
}

