//
//  Notification.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/23.
//

import Foundation

final class Notify {
    
    // MARK: - NotificationType
    
    enum NotificationType: Int, Printable {
        
        case Like
        case Comment
        case Follow
        case CommentMention
        case PostMention
        
        var description: String {
            switch self {
            case .Like: return K.NotifyDescription.like
            case .Comment: return K.NotifyDescription.comment
            case .Follow: return K.NotifyDescription.follow
            case .CommentMention: return K.NotifyDescription.commentMention
            case .PostMention: return K.NotifyDescription.postMention
            }
        }
        
        init(index: Int) {
            switch index {
            case 0: self = .Like
            case 1: self = .Comment
            case 2: self = .Follow
            case 3: self = .CommentMention
            case 4: self = .PostMention
            default: self = .Like
            }
        }
    }
    
    // MARK: - Properties
    
    var creationDate: Date!
    var uid: String!
    var postId: String?
    var post: Post?
    var user: User!
    var type: Int?
    var notificationId: String?
    var notificationType: NotificationType!
    var commentId: String?
    var commentText: String?
    var didCheck = false
    
    // MARK: - init
    
    init(user: User, post: Post? = nil, dictionary: [String: Any]) {
        
        self.user = user
        
        if let post = post {
            self.post = post
        }
        
        if let creationDate = dictionary[K.Notification.creationDate] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        if let notificationId = dictionary[K.Notification.notificationId] as? String {
            self.notificationId = notificationId
        }
        if let type = dictionary[K.Notification.type] as? Int {
            self.notificationType = NotificationType(index: type)
        }
        
        if let uid = dictionary[K.Notification.uid] as? String {
            self.uid = uid
        }
        
        if let postId = dictionary[K.Notification.postId] as? String {
            self.postId = postId
        }
        
        if let commentId = dictionary[K.Notification.commentId] as? String {
            self.commentId = commentId
        }
        
        if let checked = dictionary[K.Notification.checked] as? Int {
            self.didCheck = checked == 0 ? false : true
        }
    }
    
}
