//
//  UIViewController+Utils.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/15.
//

import UIKit
import JGProgressHUD

extension UIViewController {
    static let hud = JGProgressHUD(style: .dark)
}

// MARK: - Config UI

extension UIViewController {
    
    func configGradientLayer() {
        let gradient = CAGradientLayer()
        
        gradient.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemMint.cgColor
        ]
        
        gradient.locations = [0, 1]
        
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
    func showLoader(_ show: Bool) {
        view.endEditing(true)
        
        if show {
            Self.hud.show(in: view)
        } else {
            Self.hud.dismiss()
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
}

// MARK: - @objc Actions

extension UIViewController {
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: - Service

extension UIViewController {
    
    func uploadMentionNotification(forPostId postId: String, withText text: String, isForComment: Bool) {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        
        var mentionIntegerValue: Int!
        
        if isForComment {
            mentionIntegerValue = COMMENT_MENTION_INT_VALUE
        } else {
            mentionIntegerValue = POST_MENTION_INT_VALUE
        }
        
        for var word in words {
            if word.hasPrefix(K.String.mention) {
                word = word.trimmingCharacters(in: .symbols)
                word = word.trimmingCharacters(in: .punctuationCharacters)
                
                USERS_REF.observe(.childAdded, with: { (snapshot) in
                    let uid = snapshot.key
                    
                    USERS_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let dictionary = snapshot.value as? [String: Any] else { return }
                        
                        if word == dictionary[K.UserData.username] as? String {
                            let notificationValues = [
                                K.Notification.postId: postId,
                                K.Notification.uid: currentUid,
                                K.Notification.type: mentionIntegerValue ?? K.String.empty,
                                K.Notification.creationDate: creationDate
                            ] as [String: Any]
                            
                            if currentUid != uid {
                                NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(notificationValues)
                            }
                        }
                    })
                })
            }
        }
    }
    
}
