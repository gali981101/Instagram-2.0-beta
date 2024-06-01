//
//  Message.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/23.
//

import Foundation

final class Message {
    
    var messageText: String!
    var fromId: String!
    var toId: String!
    var creationDate: Date!
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    var videoUrl: String?
    var read: Bool!
    
    // MARK: - init
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let messageText = dictionary["messageText"] as? String {
            self.messageText = messageText
        }
        
        if let fromId = dictionary["fromId"] as? String {
            self.fromId = fromId
        }
        
        if let toId = dictionary["toId"] as? String {
            self.toId = toId
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let imageHeight = dictionary["imageHeight"] as? NSNumber {
            self.imageHeight = imageHeight
        }
        
        if let imageWidth = dictionary["imageWidth"] as? NSNumber {
            self.imageWidth = imageWidth
        }
        
        if let videoUrl = dictionary["videoUrl"] as? String {
            self.videoUrl = videoUrl
        }
        
        if let read = dictionary["read"] as? Bool {
            self.read = read
        }
    }
    
}

// MARK: - Partner Id

extension Message {
    
    func getChatPartnerId() -> String {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return K.String.empty }
        return fromId == currentUid ? toId : fromId
    }
    
}
