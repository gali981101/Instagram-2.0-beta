//
//  CommentService.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/29.
//

import FirebaseDatabaseInternal

// MARK: - CommentEventType

enum CommentEventType {
    case added
    case removed
}

// MARK: - Fetch

enum CommentService {
    
    static func fetchComments(postId: String, completion: @escaping ([String: Any], String, CommentEventType) -> Void) {
        COMMENT_REF.child(postId).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary[K.Comment.uid] as? String else { return }
            
            completion(dictionary, uid, .added)
        }
        
        COMMENT_REF.child(postId).observe(.childRemoved) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary[K.Comment.uid] as? String else { return }
            
            completion(dictionary, uid, .removed)
        }
    }
    
}

// MARK: - Delete

extension CommentService {
    
    static func deleteComment(postId: String, commentId: String, completion: @escaping ((Error?), DatabaseReference) -> Void) {
        COMMENT_REF.child(postId).child(commentId).removeValue(completionBlock: completion)
    }
    
}
