//
//  Comment.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/22.
//

import UIKit

final class Comment {
    
    var uid: String!
    var commentId: String!
    var commentText: String!
    var creationDate: Date!
    var user: User?
    
    // MARK: - init
    
    init(user: User, dict: [String: Any]) {
        
        self.user = user
        
        if let uid = dict[K.Comment.uid] as? String {
            self.uid = uid
        }
        
        if let commentId = dict[K.Comment.commentId] as? String {
            self.commentId = commentId
        }
        
        if let commentText = dict[K.Comment.commentText] as? String {
            self.commentText = commentText
        }
        
        if let creationDate = dict[K.Post.creationDate] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
}

// MARK: - Methods

extension Comment {
     
    func size(forWidth width: CGFloat) -> CGSize {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.text = self.commentText
        label.lineBreakMode = .byWordWrapping
        
        label.setWidth(width)
        
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
}
