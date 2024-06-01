//
//  Protocols.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/15.
//

// MARK: - View

protocol FeedCellDelegate: AnyObject {
    func handleUsernameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
    func handleCaptionsTapped(for cell: FeedCell)
    func configureCommentIndicatorView(for cell: FeedCell)
}

protocol UserProfileHeaderDelegate: AnyObject {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}

protocol NotificationCellDelegate: AnyObject {
    func handleProfileImageViewTapped(for cell: NotificationCell)
    func handleFollowTapped(for cell: NotificationCell)
    func handlePostTapped(for cell: NotificationCell)
}

protocol CommentInputAccesoryViewDelegate: AnyObject {
    func didSubmit(forComment comment: String)
}

protocol MessageInputAccesoryViewDelegate {
    func handleUploadMessage(message: String)
    func handleSelectImage()
}

protocol FollowCellDelegate: AnyObject {
    func handleFollowTapped(for cell: FollowLikeCell)
}

protocol ChatCellDelegate: AnyObject {
    func handlePlayVideo(for cell: ChatCell)
}

protocol MessageCellDelegate: AnyObject {
    func configureUserData(for cell: MessageCell)
}

protocol Printable {
    var description: String { get }
}

// MARK: - Controller

protocol UploadPostVCDelegate: AnyObject {
    func controllerDidDismiss(vc: UploadPostVC, action: UploadAction)
    func sharePost(vc: UploadPostVC, action: UploadAction)
}






