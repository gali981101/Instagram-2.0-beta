//
//  NotificationCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/15.
//

import UIKit

final class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?
    
    var notification: Notify? { didSet { config() } }
    
    // MARK: - UIElement
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 48 / 2
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleProfileImageViewTapped)
        )
        
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 3
        
        button.setTitle(K.ButtonTitle.loading, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handlePostTapped)
        )
        
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set Up

extension NotificationCell {
    
    private func configUI() {
        selectionStyle = .none
        contentView.isUserInteractionEnabled = false
        
        addSubview(profileImageView)
        addSubview(infoLabel)
        addSubview(followButton)
        addSubview(postImageView)
        
        layout()
    }
    
    private func layout() {
        profileImageView.setDimensions(height: 48, width: 48)
        
        followButton.centerY(inView: self)
        postImageView.centerY(inView: self)
        
        profileImageView.centerY(
            inView: self,
            leftAnchor: leftAnchor,
            paddingLeft: 12
        )
        
        followButton.anchor(
            right: rightAnchor,
            paddingRight: 15,
            width: 88,
            height: 32
        )
        
        postImageView.anchor(
            right: rightAnchor,
            paddingRight: 15,
            width: 40,
            height: 40
        )
        
        infoLabel.centerY(
            inView: profileImageView,
            leftAnchor: profileImageView.rightAnchor,
            paddingLeft: 8
        )
        
        infoLabel.anchor(
            right: followButton.leftAnchor,
            paddingRight: 4
        )
    }
    
}

// MARK: - Configure

extension NotificationCell {
    
    private func config() {
        guard let user = notification?.user else { return }
        guard let profileImageUrl = user.profileImageUrl else { return }
        
        configureNotificationType()
        configureNotificationLabel(withCommentText: nil)
        
        if let url = URL(string: profileImageUrl) {
            profileImageView.sd_setImage(with: url)
        }
        
        if let post = notification?.post,
           let firstImageString = post.imageUrls.first,
           let url = URL(string: firstImageString) {
            postImageView.sd_setImage(with: url)
        }
    }
    
    private func configureNotificationType() {
        
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
        
        if notification.notificationType != .Follow {
            followButton.isHidden = true
            postImageView.isHidden = false
            
        } else {
            followButton.isHidden = false
            postImageView.isHidden = true
            
            user.checkIfUserIsFollowed() { followed in
                if followed {
                    self.followButton.setTitle(K.FollowStats.following, for: .normal)
                } else {
                    self.followButton.setTitle(K.FollowStats.follow, for: .normal)
                }
            }
        }
    }
    
    func configureNotificationLabel(withCommentText commentText: String?) {
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
        guard let username = user.username else { return }
        guard let notificationDate = getNotificationTimeStamp() else { return }
        
        var notificationMessage: String!
        
        if let commentText = commentText {
            if notification.notificationType != .CommentMention {
                notificationMessage = "\(notification.notificationType.description): \(commentText)"
            }
        } else {
            notificationMessage = notification.notificationType.description
        }
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        attributedText.append(NSAttributedString(string: " \(notificationDate)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        infoLabel.attributedText = attributedText
    }
    
}

// MARK: - @objc Actions

extension NotificationCell {
    
    @objc private func handleProfileImageViewTapped() {
        delegate?.handleProfileImageViewTapped(for: self)
    }
    
    @objc private func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
    @objc private func handlePostTapped() {
        delegate?.handlePostTapped(for: self)
    }
    
}

// MARK: - Helper Methods

extension NotificationCell {
    
    private func getNotificationTimeStamp() -> String? {
        guard let notification = self.notification else { return nil }
        
        let now = Date()
        let dateFormatter = DateComponentsFormatter()
        
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        
        return dateFormatter.string(from: notification.creationDate, to: now)
    }
    
}
