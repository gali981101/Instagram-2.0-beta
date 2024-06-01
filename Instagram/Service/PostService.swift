//
//  PostService.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/25.
//

import UIKit
import FirebaseDatabase

// MARK: - PostService

struct PostService {
    
    private static var imageUrls: [String] = []
    
    // MARK: - init
    
    private init() {}
}

// MARK: - Upload Post

extension PostService {
    
    static func uploadPost(caption: String, images: [UIImage], completion: @escaping(String) -> Void) {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        
        startUploading(images: images) {
            let values = [
                K.Post.caption: caption,
                K.Post.creationDate: Int(NSDate().timeIntervalSince1970),
                K.Post.likes: 0,
                K.Post.imageUrls: imageUrls,
                K.Post.ownerUid: currentUid
            ] as [String: Any]
            
            let postId = POSTS_REF.childByAutoId()
            guard let postKey = postId.key else { return }
            
            postId.updateChildValues(values) { error, ref in
                
                let userPostsRef = USER_POSTS_REF.child(currentUid)
                userPostsRef.updateChildValues([postKey: 1])
                
                updateUserFeeds(with: postKey)
                completion(postKey)
            }
        }
    }
    
}

// MARK: - Upload Multiple Images

extension PostService {
    
    private static func startUploading(images: [UIImage], completion: @escaping () -> Void) {
        imageUrls = []
        
        if images.count == 0 {
            completion()
            return
        }
        uploadImages(images: images, forIndex: 0, completion: completion)
    }
    
    private static func uploadImages(images: [UIImage], forIndex i: Int, completion: @escaping () -> Void) {
        if i < images.count {
            ImageUploader.uploadImage(image: images[i], isPost: true) { url in
                imageUrls.append(url)
                uploadImages(images: images, forIndex: i + 1, completion: completion)
            }
            return
        }
        completion()
    }
    
}

// MARK: - Fetch Post

extension PostService {
    
    static func fetchPost(with postId: String, completion: @escaping(Post) -> Void) {
        
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let ownerUid = dictionary[K.Post.ownerUid] as? String else { return }
            
            UserService.fetchUserData(with: ownerUid) { user in
                let post = Post(postId: postId, user: user, dict: dictionary)
                completion(post)
            }
        }
    }
    
}

// MARK: - Fetch User Posts

extension PostService {
    
    static func fetchCurrentPosts(
        ref: DatabaseReference? = nil,
        uid: String? = nil,
        limit: UInt,
        vc: UIViewController,
        completion: @escaping (DataSnapshot, [DataSnapshot]) -> Void
    ) {
        
        var database: DatabaseReference?
        
        if let ref = ref, let uid = uid {
            database = ref.child(uid)
        } else {
            database = POSTS_REF
        }
        
        guard let database = database else { fatalError() }
        
        database.queryLimited(toLast: limit).observeSingleEvent(of: .value) { snapshot in
            
            guard let first = snapshot.children.allObjects.first as? DataSnapshot else {
                vc.showLoader(false)
                return
            }
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            completion(first, allObjects)
        }
        
    }
    
    static func fetchOldPosts(
        ref: DatabaseReference? = nil,
        uid: String? = nil,
        key: String?,
        limit: UInt,
        completion: @escaping (DataSnapshot, [DataSnapshot]) -> Void
    ) {
        
        var database: DatabaseReference?
        
        if let ref = ref, let uid = uid {
            database = ref.child(uid)
        } else {
            database = POSTS_REF
        }
        
        guard let database = database else { fatalError() }
        
        database
            .queryOrderedByKey()
            .queryEnding(atValue: key)
            .queryLimited(toLast: limit)
            .observeSingleEvent(of: .value) { snapshot in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                completion(first, allObjects)
            }
    }
    
}

// MARK: - Update

extension PostService {
    
    private static func updateUserFeeds(with postId: String) {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        let values = [postId: 1]
        
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        
        USER_FEED_REF.child(currentUid).updateChildValues(values)
    }
    
}

// MARK: - Delete

extension PostService {
    
    static func startDeleting(postId: String, completion: @escaping (Bool) -> Void) {
        fetchPost(with: postId) { post in
            guard let urls = post.imageUrls else {
                completion(false)
                return
            }
            deleteImages(urls: urls, forIndex: (urls.count - 1), completion: completion)
        }
    }
    
    static func deleteImages(urls: [String], forIndex i: Int, completion: @escaping (Bool) -> Void) {
        if i >= 0 {
            ImageDeleter.deleteImage(url: urls[i]) {
                deleteImages(urls: urls, forIndex: i - 1, completion: completion)
            }
            return
        }
        
        completion(true)
    }
    
}
