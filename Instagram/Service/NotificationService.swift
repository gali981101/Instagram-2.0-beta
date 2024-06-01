//
//  NotificationService.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/31.
//

import UIKit
import FirebaseDatabaseInternal

enum NotificationService {
    
    static func getNotifications(_ currentUid: String, vc: UIViewController, completion: @escaping (String, [String: Any], String) -> Void) {
        NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach { snapshot in
                let notificationId = snapshot.key
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary[K.Notification.uid] as? String else { return }
                
                completion(notificationId, dictionary, uid)
            }
        }
    }
    
    static func deleteNotification(
        currentUid: String,
        notificationId: String,
        completion: @escaping ((Error?), DatabaseReference) -> Void) {
            NOTIFICATIONS_REF.child(currentUid).child(notificationId).removeValue(completionBlock: completion)
        }
    
}
