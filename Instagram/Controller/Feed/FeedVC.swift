//
//  FeedVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/17.
//

import UIKit
import ActiveLabel
import FirebaseAuth

private let reuseIdentifier: String = K.CellId.feedCell

// MARK: - FeedVC

final class FeedVC: UICollectionViewController {
    
    // MARK: - Properties
    
    private var post: Post?
    private var userProfileController: UserProfileVC?
    private var currentKey: String?
    private var viewSinglePost: Bool = false
    private var isFirstLoad: Bool = true
    
    private lazy var posts: [Post] = []
    
    // MARK: - UIElement
    
    private lazy var refresher = UIRefreshControl()
    
    private lazy var logoutButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(
            title: K.ButtonTitle.logout,
            style: .done,
            target: self,
            action: #selector(handleLogout)
        )
        
        barButton.tintColor = .label
        
        return barButton
    }()
    
    private lazy var messageButton: UIBarButtonItem = {
        let image = UIImage(systemName: K.SystemImageName.paperplane)
        
        let barButton = UIBarButtonItem(
            image: image,
            style: .done,
            target: self,
            action: #selector(handleShowMessages)
        )
        
        barButton.tintColor = .label
        
        return barButton
    }()
    
    private lazy var messageNotificationView: MessageNotificationView = {
        let view = MessageNotificationView()
        return view
    }()
    
    // MARK: - init
    
    init(post: Post? = nil, userProfileController: UserProfileVC? = nil, viewSinglePost: Bool) {
        self.post = post
        self.userProfileController = userProfileController
        self.viewSinglePost = viewSinglePost
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension FeedVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !viewSinglePost && !isFirstLoad { handleRefresh() }
        if isFirstLoad { isFirstLoad = false }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}

// MARK: - Set Up

extension FeedVC {
    
    private func config() {
        collectionView?.backgroundColor = .systemBackground
        
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refresher
        
        configureNavigationBar()
        
        if !viewSinglePost { fetchPosts() }
    }
    
}

// MARK: - @objc Actions

extension FeedVC {
    
    @objc private func handleRefresh() {
        if !viewSinglePost {
            reloadPosts()
        } else {
            guard let post = post else {
                return
            }
            fetchPost(withPostId: post.postId)
        }
    }
    
    @objc private func handleLogout() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: K.ActionText.logout, style: .destructive, handler: { [weak self] (_) in
            
            guard let self else { return }
            
            do {
                try Auth.auth().signOut()
                let loginVC = LoginVC()
                
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                
                self.present(navController, animated: true, completion: nil)
            } catch {
                print(error.localizedDescription)
            }
        })
        
        actionSheet.addAction(logoutAction)
        actionSheet.addAction(UIAlertAction(title: K.ActionText.cancel, style: .cancel, handler: nil))
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = logoutButton
            popoverController.permittedArrowDirections = .up
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc private func handleShowMessages() {
        let messagesVC = MessagesVC()
        self.messageNotificationView.isHidden = true
        navigationController?.pushViewController(messagesVC, animated: true)
    }
    
}

// MARK: - Handlers

extension FeedVC {
    
    private func configureNavigationBar() {
        self.title = K.instagram
        
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = logoutButton
            self.navigationItem.rightBarButtonItem = messageButton
        }
    }
    
    private func handleHashtagTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleHashtagTap { hashtag in
        }
    }
    
    private func handleMentionTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleMentionTap { username in
        }
    }
    
    private func handleUsernameLabelTapped(forCell cell: FeedCell) {
        guard let user = cell.post?.user else { return }
        guard let username = user.username else { return }
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        cell.captionLabel.handleCustomTap(for: customType) { [weak self] _ in
            guard let self else { return }
            let userProfileController = UserProfileVC(user: user)
            self.navigationController?.pushViewController(userProfileController, animated: true)
        }
    }
    
}

// MARK: - Service

extension FeedVC {
    
    private func fetchPosts() {
        showLoader(true)
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.endRefresher()
        
        if currentKey == nil {
            PostService.fetchCurrentPosts(ref: USER_FEED_REF, uid: currentUid, limit: 5, vc: self) { [weak self] first, objects in
                guard let self else { return }
                
                objects.forEach { snapshot in
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                }
                self.currentKey = first.key
                showLoader(false)
            }
        } else {
            PostService.fetchOldPosts(ref: USER_FEED_REF, uid: currentUid, key: self.currentKey, limit: 6) { [weak self] first, objects in
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
            
            if viewSinglePost {
                DispatchQueue.main.async {
                    self.post = post
                    self.collectionView.reloadData()
                    self.endRefresher()
                }
            } else {
                collectionView.performBatchUpdates {
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
    }
    
    private func reloadPosts() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            posts.removeAll(keepingCapacity: false)
            self.currentKey = nil
            fetchPosts()
            collectionView?.reloadData()
        }
    }
    
}

// MARK: - Helper Methods

extension FeedVC {
    
    private func endRefresher() {
        if refresher.isRefreshing {
            // 讓動畫效果更佳，在結束更新之前延遲 0.5秒
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [unowned self] in
                refresher.endRefreshing()
            }
        }
    }
    
    private func handleEditPost() {
    }
    
    private func handleDeletePost(post: Post) {
        post.deletePost { [weak self] in
            guard let self else { return }
            
            if !viewSinglePost {
                reloadPosts()
            } else {
                collectionView.reloadData()
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension FeedVC {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewSinglePost {
            return 1
        } else {
            return posts.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        
        cell.delegate = self
        cell.viewSinglePost = self.viewSinglePost
        
        if viewSinglePost {
            if let post = self.post {
                cell.post = post
            }
        } else {
            cell.post = posts[indexPath.item]
        }
        
        handleHashtagTapped(forCell: cell)
        handleUsernameLabelTapped(forCell: cell)
        handleMentionTapped(forCell: cell)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension FeedVC {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (posts.count > 4) && (indexPath.item == posts.count - 1) { fetchPosts() }
    }
    
}

// MARK: - UICollectionViewFlowLayout

extension FeedVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        var height = width + 8 + 140 + 8
        
        height += 50
        height += 60
        
        if viewSinglePost { height += 350 }
        
        return CGSize(width: width, height: height)
    }
    
}

// MARK: - FeedCellDelegate

extension FeedVC: FeedCellDelegate {
    
    func handleUsernameTapped(for cell: FeedCell) {
        guard let post = cell.post, !(self.viewSinglePost) else { return }
        let userProfileVC = UserProfileVC(user: post.user)
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        guard let post = cell.post, post.ownerUid == Auth.auth().currentUser?.uid else { return }
        
        let actionSheet = UIAlertController(title: K.AlertTitle.options, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: K.ActionText.edit, style: .default) { [weak self] _ in
            guard let self else { return }
            self.handleEditPost()
        }
        
        let deleteAction = UIAlertAction(title: K.ActionText.delete, style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.handleDeletePost(post: post)
        }
        
        let cancelAction = UIAlertAction(title: K.ActionText.cancel, style: .cancel, handler: nil)
        
        actionSheet.addAction(editAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = cell.optionsButton
            popoverController.permittedArrowDirections = .up
        }
        
        present(actionSheet, animated: true)
    }
    
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
        guard let post = cell.post else { return }
        
        if post.didLike {
            if !isDoubleTap {
                cell.likeButton.isEnabled = false
                
                // 取消按讚
                post.adjustLikes(addLike: false) { likes in
                    let heart = UIImage(systemName: K.SystemImageName.heart)
                    
                    cell.likesLabel.text = "\(likes) \(K.Post.likes)"
                    cell.likeButton.tintColor = .label
                    cell.likeButton.setImage(heart, for: .normal)
                    cell.likeButton.isEnabled = true
                }
            }
        } else {
            cell.likeButton.isEnabled = false
            
            // 按讚
            post.adjustLikes(addLike: true) { likes in
                cell.likesLabel.text = "\(likes) \(K.Post.likes)"
                cell.likeButton.animateHeart()
                cell.likeButton.isEnabled = true
            }
        }
        
    }
    
    func handleCommentTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let commentVC = CommentVC(post: post)
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(postId) {
                let heartFillImage = UIImage(systemName: K.SystemImageName.heartFill)
                
                post.didLike = true
                cell.likeButton.tintColor = .red
                cell.likeButton.setImage(heartFillImage, for: .normal)
            } else {
                let heartImage = UIImage(systemName: K.SystemImageName.heart)
                
                post.didLike = false
                cell.likeButton.tintColor = .label
                cell.likeButton.setImage(heartImage, for: .normal)
            }
        }
    }
    
    func handleShowLikes(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        
        let followLikeVC = FollowLikeVC()
        
        followLikeVC.viewingMode = ViewingMode(index: 2)
        followLikeVC.postId = postId
        
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    func handleCaptionsTapped(for cell: FeedCell) {
        if !viewSinglePost {
            let feedVC = FeedVC(post: cell.post, viewSinglePost: true)
            navigationController?.pushViewController(feedVC, animated: true)
        }
    }
    
    func configureCommentIndicatorView(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        
        COMMENT_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                cell.addCommentIndicatorView(toStackView: cell.stackView)
            } else {
                cell.commentIndicatorView.isHidden = true
            }
        }
    }
    
}








