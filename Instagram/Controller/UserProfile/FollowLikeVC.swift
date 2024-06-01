//
//  FollowLikeVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/23.
//

import UIKit

private let followCellId = K.CellId.followCell

// MARK: - Viewing Mode

enum ViewingMode: Int {
    
    case Following
    case Followers
    case Likes
    
    init(index: Int) {
        switch index {
        case 0: self = .Following
        case 1: self = .Followers
        case 2: self = .Likes
        default: self = .Following
        }
    }
}

// MARK: - FollowLikeVC

final class FollowLikeVC: UITableViewController {
    
    // MARK: - Properties
    
    var followCurrentKey: String?
    var likeCurrentKey: String?
    
    var postId: String?
    var uid: String?
    var viewingMode: ViewingMode!
    
    private lazy var users: [User] = []
    
}

// MARK: - Life Cycle

extension FollowLikeVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: followCellId)
        tableView.separatorStyle = .none
        
        configureNavigationTitle()
        
        fetchUsers()
    }
    
}

// MARK: - Config

extension FollowLikeVC {
    
    private func configureNavigationTitle() {
        guard let viewingMode = self.viewingMode else { return }
        
        switch viewingMode {
        case .Followers: navigationItem.title = K.VCName.followers
        case .Following: navigationItem.title = K.VCName.following
        case .Likes: navigationItem.title = K.VCName.likes
        }
    }
    
}

// MARK: - Handlers

extension FollowLikeVC {
    
    private func loadCurrentFollwers(uid: String) {
        guard let ref = getDatabaseReference(viewingMode: self.viewingMode) else { return }
        
        UserService.fetchSomeUsers(ref: ref, id: uid) { [weak self] first, objects in
            guard let self else { return }
            
            objects.forEach { snapshot in
                let followUid = snapshot.key
                self.fetchUser(withUid: followUid)
            }
            
            self.followCurrentKey = first.key
        }
    }
    
    private func loadOldFollowers(uid: String) {
        guard let ref = getDatabaseReference(viewingMode: self.viewingMode) else { return }
        
        UserService.fetchSomeOldUsers(ref: ref, id: uid, key: self.followCurrentKey) { [weak self] first, objects in
            guard let self else { return }
            
            objects.forEach { (snapshot) in
                let followUid = snapshot.key
                if followUid != self.followCurrentKey { self.fetchUser(withUid: followUid) }
            }
            
            self.followCurrentKey = first.key
        }
    }
    
    private func loadCurrentLikers(postId: String) {
        guard let ref = getDatabaseReference(viewingMode: self.viewingMode) else { return }
        
        UserService.fetchSomeUsers(ref: ref, id: postId) { [weak self] first, objects in
            guard let self else { return }
            
            objects.forEach { snapshot in
                let likeUid = snapshot.key
                self.fetchUser(withUid: likeUid)
            }
            
            self.likeCurrentKey = first.key
        }
    }
    
    private func loadOldLikers(postId: String) {
        guard let ref = getDatabaseReference(viewingMode: self.viewingMode) else { return }
        
        UserService.fetchSomeOldUsers(ref: ref, id: postId, key: self.likeCurrentKey) { [weak self]  first, objects in
            guard let self else { return }
            
            objects.forEach { (snapshot) in
                let likeUid = snapshot.key
                if likeUid != self.likeCurrentKey { self.fetchUser(withUid: likeUid) }
            }
            
            self.likeCurrentKey = first.key
        }
    }
    
}

// MARK: - Service

extension FollowLikeVC {
    
    private func fetchUser(withUid uid: String) {
        UserService.fetchUserData(with: uid) { [weak self] user in
            guard let self else { return }
            
            DispatchQueue.main.async {
                let i = IndexPath(row: self.users.count, section: 0)
                self.users.append(user)
                self.tableView.insertRows(at: [i], with: .automatic)
            }
        }
    }
    
    private func fetchUsers() {
        guard let viewingMode = self.viewingMode else { return }
        
        switch viewingMode {
        case .Followers, .Following:
            guard let uid = self.uid else { return }
            
            if followCurrentKey == nil {
                loadCurrentFollwers(uid: uid)
            } else {
                loadOldFollowers(uid: uid)
            }
        case .Likes:
            guard let postId = self.postId else { return }
            
            if likeCurrentKey == nil {
                loadCurrentLikers(postId: postId)
            } else {
                loadOldLikers(postId: postId)
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension FollowLikeVC {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: followCellId, for: indexPath) as! FollowLikeCell
        
        cell.delegate = self
        cell.user = users[indexPath.row]
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension FollowLikeVC {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (users.count > 3) && (indexPath.item == users.count - 1) { fetchUsers() }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let userProfileVC = UserProfileVC(user: user)
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
}

// MARK: - FollowCellDelegate

extension FollowLikeVC: FollowCellDelegate {
    
    func handleFollowTapped(for cell: FollowLikeCell) {
        guard let user = cell.user else { return }
        
        if user.isFollowed {
            user.unfollow() {
                cell.followButton.setTitle(K.FollowStats.follow, for: .normal)
            }
        } else {
            user.follow() {
                cell.followButton.setTitle(K.FollowStats.following, for: .normal)
            }
        }
    }
    
}






