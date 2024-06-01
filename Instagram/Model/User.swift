//
//  User.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/19.
//

import Foundation

final class User {
    
    // MARK: - Properties
    
    var uid: String!
    var username: String!
    var fullname: String!
    var profileImageUrl: String!
    
    var isFollowed: Bool = false
    
    // MARK: - init
    
    init(uid: String, dict: [String: Any]) {
        self.uid = uid
        
        if let username = dict[K.UserData.username] as? String {
            self.username = username
        }
        
        if let fullname = dict[K.UserData.fullname] as? String {
            self.fullname = fullname
        }
        
        if let profileImageUrl = dict[K.UserData.profileImage] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
    
}

// MARK: - User Follow

extension User {
    
    func follow(completion: @escaping () -> Void) {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        guard let uid = uid else { return }
        
        self.isFollowed = true
        
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUid: 1])
        
        uploadFollowNotificationToServer()
        
        // add followed users posts to current user-feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        }
        
        completion()
    }
    
    func unfollow(completion: @escaping () -> Void) {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        guard let uid = uid else { return }
        
        self.isFollowed = false
        
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()
        
        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue()
        
        // add followed users posts to current user-feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).child(postId).removeValue()
        }
        
        completion()
    }
    
    func checkIfUserIsFollowed(completion: @escaping (Bool) -> Void) {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.hasChild(self.uid) {
                self.isFollowed = true
                completion(true)
            } else {
                self.isFollowed = false
                completion(false)
            }
        }
    }
    
}


// MARK: - Notification

extension User {
    
    private func uploadFollowNotificationToServer() {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = [
            K.Notification.checked: 0,
            K.Notification.creationDate: creationDate,
            K.Notification.uid: currentUid,
            K.Notification.type: FOLLOW_INT_VALUE
        ] as [String : Any]
        
        
        NOTIFICATIONS_REF.child(self.uid).childByAutoId().updateChildValues(values)
    }
    
}







