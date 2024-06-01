//
//  Post.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/19.
//

import Foundation

final class Post {
    
    var caption: String!
    var likes: Int!
    var imageUrls: [String]!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    var didLike = false
    
    // MARK: - init
    
    init(postId: String, user: User, dict: [String: Any]) {
        
        self.postId = postId
        
        self.user = user
        
        if let caption = dict[K.Post.caption] as? String {
            self.caption = caption
        }
        
        if let likes = dict[K.Post.likes] as? Int {
            self.likes = likes
        }
        
        if let imageUrls = dict[K.Post.imageUrls] as? [String] {
            self.imageUrls = imageUrls
        }
        
        if let ownerUid = dict[K.Post.ownerUid] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dict[K.Post.creationDate] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
}

// MARK: - Post Likes

extension Post {
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        guard let postId = self.postId else { return }
        
        if addLike {
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1]) { [weak self] err, ref in
                guard let self else { return }
                
                self.sendLikeNotificationToServer()
                
                POST_LIKES_REF.child(self.postId).updateChildValues([currentUid: 1]) { err, ref in
                    self.likes = self.likes + 1
                    self.didLike = true
                    POSTS_REF.child(self.postId).child(K.Post.likes).setValue(self.likes)
                    
                    completion(self.likes)
                }
            }
        } else {
            USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self else { return }
                
                if let notificationID = snapshot.value as? String {
                    NOTIFICATIONS_REF.child(self.ownerUid).child(notificationID).removeValue() { err, ref in
                        self.removeLike { likes in completion(likes) }
                    }
                } else {
                    self.removeLike { likes in completion(likes) }
                }
            }
        }
    }
    
    func removeLike(completion: @escaping (Int) -> ()) {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        
        USER_LIKES_REF.child(currentUid).child(self.postId).removeValue() { [weak self] err, ref in
            guard let self else { return }
            
            POST_LIKES_REF.child(self.postId).child(currentUid).removeValue() { err, ref in
                guard self.likes > 0 else { return }
                
                self.likes = self.likes - 1
                self.didLike = false
                
                POSTS_REF.child(self.postId).child(K.Post.likes).setValue(self.likes)
                
                completion(self.likes)
            }
        }
    }
    
}

// MARK: - Delete Post

extension Post {
    
    func deletePost(completion: @escaping () -> Void) {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        
        PostService.startDeleting(postId: self.postId) { [weak self] success in
            if !success { fatalError() }
            guard let self else { return }
            
            USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { snapshot in
                let followerUid = snapshot.key
                USER_FEED_REF.child(followerUid).child(self.postId).removeValue()
            }
            
            USER_FEED_REF.child(currentUid).child(postId).removeValue()
            
            USER_POSTS_REF.child(currentUid).child(postId).removeValue()
            
            POST_LIKES_REF.child(postId).observe(.childAdded) { snapshot in
                let uid = snapshot.key
                
                USER_LIKES_REF.child(uid).child(self.postId).observeSingleEvent(of: .value) { snapshot in
                    guard let notificationId = snapshot.value as? String else { return }
                    
                    NOTIFICATIONS_REF.child(self.ownerUid).child(notificationId).removeValue() { err, ref in
                        
                        POST_LIKES_REF.child(self.postId).removeValue()
                        
                        USER_LIKES_REF.child(uid).child(self.postId).removeValue()
                    }
                }
            }
            
            let words = caption.components(separatedBy: .whitespacesAndNewlines)
            
            for var word in words {
                if word.hasPrefix("#") {
                    
                    word = word.trimmingCharacters(in: .punctuationCharacters)
                    word = word.trimmingCharacters(in: .symbols)
                    
                    HASHTAG_POST_REF.child(word).child(postId).removeValue()
                }
            }
            
            COMMENT_REF.child(postId).removeValue()
            POSTS_REF.child(postId).removeValue()
            
            completion()
        }
    }
    
}

// MARK: - Notification

extension Post {
    
    private func sendLikeNotificationToServer() {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        guard let postId = self.postId else { return }
        
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        if currentUid != self.ownerUid {
            let values = [
                K.Notification.checked: 0,
                K.Notification.creationDate: creationDate,
                K.Notification.uid: currentUid,
                K.Notification.type: LIKE_INT_VALUE,
                K.Notification.postId: postId
            ] as [String : Any]
            
            let notificationRef = NOTIFICATIONS_REF.child(self.ownerUid).childByAutoId()
            
            notificationRef.updateChildValues(values) { err, ref in
                USER_LIKES_REF.child(currentUid).child(self.postId).setValue(notificationRef.key)
            }
        }
    }
    
}




















