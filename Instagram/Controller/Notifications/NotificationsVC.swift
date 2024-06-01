//
//  NotificationsVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/17.
//

import UIKit

private let notificationCell = K.CellId.notificationCell

final class NotificationsVC: UITableViewController {
    
    // MARK: - Properties
    
    private lazy var notifications: [Notify] = []
    
    // MARK: - UIElement
    
    private lazy var refresher = UIRefreshControl()
}


// MARK: - Life Cycle

extension NotificationsVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        fetchNotifications()
    }
    
}

// MARK: - Set

extension NotificationsVC {
    
    private func configUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = K.VCName.notifications
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: notificationCell)
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        tableView.showsVerticalScrollIndicator = false
        
        configureRefreshControl()
    }
    
}

// MARK: - @objc Actions

extension NotificationsVC {
    
    @objc private func handleRefresh() {
        self.notifications.removeAll()
        self.tableView.reloadData()
        fetchNotifications()
        refresher.endRefreshing()
    }
    
}

// MARK: - Service

extension NotificationsVC {
    
    private func getCommentData(forNotification notification: Notify) {
        
        guard let postId = notification.postId else { return }
        guard let commentId = notification.commentId else { return }
        
        COMMENT_REF.child(postId).child(commentId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let commentText = dictionary[K.Comment.commentText] as? String else { return }
            
            notification.commentText = commentText
        }
    }
    
    private func fetchNotifications() {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        
        NotificationService.getNotifications(currentUid, vc: self) { [weak self] notificationId, dict, uid in
            guard let self else { return }
            
            UserService.fetchUserData(with: uid) { user in
                if let postId = dict[K.Post.postId] as? String {
                    PostService.fetchPost(with: postId) { post in
                        let notification = Notify(user: user, post: post, dictionary: dict)
                        
                        if notification.notificationType == .Comment {
                            self.getCommentData(forNotification: notification)
                        }
                        
                        self.handleSortNotifications(notification: notification)
                    }
                } else {
                    let notification = Notify(user: user, dictionary: dict)
                    self.handleSortNotifications(notification: notification)
                }
            }
            
            NOTIFICATIONS_REF.child(currentUid).child(notificationId).child(K.Notification.checked).setValue(1)
            NOTIFICATIONS_REF.child(currentUid).child(notificationId).child(K.Notification.notificationId).setValue(notificationId)
        }
    }
    
}

// MARK: - Handlers

extension NotificationsVC {
    
    private func handleSortNotifications(notification: Notify) {
        self.notifications.sort { (notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        }
        
        DispatchQueue.main.async { [unowned self] in
            notifications.append(notification)
            
            notifications.sort { notification1, notification2 -> Bool in
                return notification1.creationDate > notification2.creationDate
            }
            
            if let sortedIndex = notifications.firstIndex(where: { $0.notificationId == notification.notificationId }) {
                let i = IndexPath(row: sortedIndex, section: 0)
                tableView.insertRows(at: [i], with: .automatic)
            } else {
                tableView.reloadData()
            }
        }
    }
    
}

// MARK: - Helper Methods

extension NotificationsVC {
    
    private func configureRefreshControl() {
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableView.refreshControl = refresher
    }
    
    private func endRefresher() {
        if refresher.isRefreshing {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [unowned self] in
                refresher.endRefreshing()
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension NotificationsVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: notificationCell,
            for: indexPath
        ) as! NotificationCell
        
        let notification = notifications[indexPath.row]
        
        cell.notification = notification
        cell.delegate = self
        
        if notification.notificationType == .Comment {
            if let commentText = notification.commentText {
                cell.configureNotificationLabel(withCommentText: commentText)
            }
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension NotificationsVC {
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: K.String.empty) { [weak self] action, sourceView, completion in
            if let currentUid = AuthService.shared.getCurrentUserUid(),
               let id = self?.notifications[indexPath.row].notificationId {
                NotificationService.deleteNotification(currentUid: currentUid, notificationId: id) { [weak self] error, _ in
                    if error != nil { fatalError() }
                    self?.notifications.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                    
                    completion(true)
                }
            }
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: K.SystemImageName.trash)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

// MARK: - NotificationCellDelegate

extension NotificationsVC: NotificationCellDelegate {
    
    func handleProfileImageViewTapped(for cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        let profileVC = UserProfileVC(user: user)
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func handleFollowTapped(for cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            user.unfollow {
                cell.followButton.configure(didFollow: false)
            }
        } else {
            user.follow {
                cell.followButton.configure(didFollow: true)
            }
        }
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        guard let post = cell.notification?.post else { return }
        guard let notification = cell.notification else { return }
        
        if notification.notificationType == .Comment {
            let commentVC = CommentVC(post: post)
            navigationController?.pushViewController(commentVC, animated: true)
        } else {
            let feedVC = FeedVC(post: post, viewSinglePost: true)
            navigationController?.pushViewController(feedVC, animated: true)
        }
    }
    
}










