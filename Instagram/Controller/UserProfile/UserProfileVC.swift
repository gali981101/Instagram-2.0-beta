//
//  UserProfileVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/17.
//

import UIKit

private let reuseIdentifier: String = K.CellId.userPostCell
private let headerIdentifier: String = K.HeaderId.profileHeader

private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

// MARK: - UserProfileVC

final class UserProfileVC: UICollectionViewController {
    
    // MARK: - Properties
    
    var user: User?
    var currentKey: String?
    
    private lazy var posts: [Post] = []
    
    private lazy var numberOfFollwers: Int = 0
    private lazy var numberOfFollowing: Int = 0
    
    // MARK: - UIElement
    
    private lazy var refresher = UIRefreshControl()
    
    // MARK: - init
    
    init(user: User? = nil) {
        self.user = user
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension UserProfileVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
}

// MARK: - Set Up

extension UserProfileVC {
    
    private func config() {
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView!.register(
            UserProfileHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: headerIdentifier
        )
        
        self.collectionView?.backgroundColor = .systemBackground
        
        configureRefreshControl()
        
        if self.user == nil { fetchCurrentUserData() }
        fetchPosts()
    }
    
}

// MARK: - @objc Actions

extension UserProfileVC {
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }
    
}

// MARK: - Service

extension UserProfileVC {
    
    private func fetchCurrentUserData() {
        UserService.fetchUserData { user in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.user = user
                self.navigationItem.title = user.username
                self.collectionView?.reloadData()
            }
        }
    }
    
    private func fetchPosts() {
        
        showLoader(true)
        
        var uid: String!
        
        if let user = self.user {
            uid = user.uid
        } else {
            uid = AuthService.shared.getCurrentUserUid()
        }
        
        self.endRefresher()
        
        if currentKey == nil {
            PostService.fetchCurrentPosts(ref: USER_POSTS_REF, uid: uid, limit: 10, vc: self) { [weak self] first, objects in
                guard let self else { return }
                
                objects.forEach { snapshot in
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                }
                self.currentKey = first.key
                showLoader(false)
            }
        } else {
            PostService.fetchOldPosts(ref: USER_POSTS_REF, uid: uid, key: self.currentKey, limit: 7) { [weak self] first, objects in
                guard let self else { return }
                
                objects.forEach { snapshot in
                    let postId = snapshot.key
                    if postId != self.currentKey { self.fetchPost(withPostId: postId) }
                }
                self.currentKey = first.key
                showLoader(false)
            }
        }
        
    }
    
    private func fetchPost(withPostId postId: String) {
        PostService.fetchPost(with: postId) { [weak self] post in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.posts.append(post)
                
                self.posts.sort { post1, post2 -> Bool in
                    return post1.creationDate > post2.creationDate
                }
                
                if let sortedIndex = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    let i = IndexPath(row: sortedIndex, section: 0)
                    self.collectionView.insertItems(at: [i])
                } else {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func fetchUserFollwers(uid: String, completion: @escaping (NSMutableAttributedString) -> Void) {
        USER_FOLLOWER_REF.child(uid).observe(.value) { [weak self] snapshot, _ in
            guard let self else { return }
            
            if let snapshot = snapshot.value as? [String: Any] {
                numberOfFollwers = snapshot.count
            } else {
                numberOfFollwers = 0
            }
            
            let attributedText = StringFactory.attributedStatText(
                value: numberOfFollwers,
                label: K.AttributedString.followers
            )
            
            completion(attributedText)
        }
    }
    
    private func fetchUserFollwing(uid: String, completion: @escaping (NSMutableAttributedString) -> Void) {
        USER_FOLLOWING_REF.child(uid).observe(.value) { [weak self] snapshot, _ in
            guard let self else { return }
            
            if let snapshot = snapshot.value as? [String: Any] {
                numberOfFollowing = snapshot.count
            } else {
                numberOfFollowing = 0
            }
            
            let attributedText = StringFactory.attributedStatText(
                value: numberOfFollowing,
                label: K.AttributedString.following
            )
            
            completion(attributedText)
        }
    }
    
    private func fetchUserPosts(uid: String, completion: @escaping (NSMutableAttributedString) -> Void) {
        UserService.fetchUserPosts(uid: uid) { snapshot in
            let postCount = snapshot.count
            
            let attributedText = StringFactory.attributedStatText(
                value: postCount,
                label: K.AttributedString.posts
            )
            
            completion(attributedText)
        }
    }
    
}

// MARK: - Helper Methods

extension UserProfileVC {
    
    private func configureRefreshControl() {
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refresher
    }
    
    private func endRefresher() {
        if refresher.isRefreshing {
            // 讓動畫效果更佳，在結束更新之前延遲 0.5秒
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [unowned self] in
                refresher.endRefreshing()
            }
        }
    }
    
}

// MARK: - UICollectionView DataSource

extension UserProfileVC {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        navigationItem.title = user?.username
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: headerIdentifier,
            for: indexPath
        ) as! UserProfileHeader
        
        header.delegate = self
        header.user = self.user
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension UserProfileVC {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (posts.count > 9) && (indexPath.item == posts.count - 1) { fetchPosts() }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedVC(post: posts[indexPath.item], userProfileController: self, viewSinglePost: true)
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UserProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
}

// MARK: - UserProfileHeaderDelegate

extension UserProfileVC: UserProfileHeaderDelegate {
    
    func setUserStats(for header: UserProfileHeader) {
        guard let uid = header.user?.uid else { return }
        
        fetchUserFollwers(uid: uid) { attributedText in
            header.followersLabel.attributedText = attributedText
        }
        
        fetchUserFollwing(uid: uid) { attributedText in
            header.followingLabel.attributedText = attributedText
        }
        
        fetchUserPosts(uid: uid) { attributedText in
            header.postsLabel.attributedText = attributedText
        }
    }
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewingMode = ViewingMode(index: 1)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewingMode = ViewingMode(index: 0)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
        guard let user = header.user else { return }
        
        header.editProfileFollowButton.giveFeedback()
        
        if header.editProfileFollowButton.titleLabel?.text == K.ButtonTitle.editProfile {
        } else {
            if header.editProfileFollowButton.titleLabel?.text == K.FollowStats.follow {
                user.follow() {
                    header.editProfileFollowButton.setTitle(K.FollowStats.following, for: .normal)
                }
            } else {
                user.unfollow() {
                    header.editProfileFollowButton.setTitle(K.FollowStats.follow, for: .normal)
                }
            }
        }
    }
    
}
