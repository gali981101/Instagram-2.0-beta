//
//  CommentVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/28.
//

import UIKit
import IQKeyboardManagerSwift

private let commentCellId = K.CellId.commentCell

final class CommentVC: UIViewController {
    
    // MARK: - Properties
    
    private var post: Post
    private var comments: [Comment] = []
    
    // MARK: - UIElement
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        
        tv.dataSource = self
        tv.delegate = self
        
        tv.backgroundColor = .systemBackground
        
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        tv.register(CommentCell.self, forCellReuseIdentifier: commentCellId)
        
        return tv
    }()
    
    private lazy var commentInputView: CommentInputAccesoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cv = CommentInputAccesoryView(frame: frame)
        
        cv.delegate = self
        
        return cv
    }()
    
    // MARK: - init
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension CommentVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        fetchCommentsAndObserve()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
}

// MARK: - Set Up

extension CommentVC {
    
    private func config() {
        navigationItem.title = K.VCName.comment
        
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.fillSuperview()
        
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .interactive
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
}

// MARK: - Service

extension CommentVC {
    
    private func fetchCommentsAndObserve() {
        guard let postId = self.post.postId else { return }
        
        CommentService.fetchComments(postId: postId) { [weak self]  dict, uid, eventType  in
            guard let self else { return }
            
            UserService.fetchUserData(with: uid) { user in
                let comment = Comment(user: user, dict: dict)
                
                switch eventType {
                case .added:
                    DispatchQueue.main.async {
                        self.comments.append(comment)
                        
                        self.comments.sort { comment1, comment2 -> Bool in
                            return comment1.creationDate > comment2.creationDate
                        }
                        
                        if let sortedIndex = self.comments.firstIndex(where: { $0.commentId == comment.commentId }) {
                            let i = IndexPath(row: sortedIndex, section: 0)
                            self.tableView.insertRows(at: [i], with: .automatic)
                        } else {
                            self.tableView.reloadData()
                        }
                    }
                case .removed:
                    if let index = self.comments.firstIndex(where: { $0.commentId == comment.commentId }) {
                        self.comments.remove(at: index)
                        let indexPath = IndexPath(row: index, section: 0)
                        
                        DispatchQueue.main.async {
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    } else {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func uploadCommentNotificationToServer() {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        guard let postId = self.post.postId else { return }
        guard let uid = post.user?.uid else { return }
        
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = [
            K.Notification.checked: 0,
            K.Notification.creationDate: creationDate,
            K.Notification.uid: currentUid,
            K.Notification.type: COMMENT_INT_VALUE,
            K.Notification.postId: postId
        ] as [String : Any]
        
        if uid != currentUid {
            NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values)
        }
    }
    
}

// MARK: - Handlers

extension CommentVC {
    
    private func handleHashtagTapped(forCell cell: CommentCell) {
        cell.commentLabel.handleHashtagTap { hashtag in
        }
    }
    
    private func handleMentionTapped(forCell cell: CommentCell) {
        cell.commentLabel.handleMentionTap { username in
        }
    }
    
}

// MARK: - UITableViewDataSource

extension CommentVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! CommentCell
        
        handleHashtagTapped(forCell: cell)
        handleMentionTapped(forCell: cell)
        
        cell.comment = comments[indexPath.item]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let comment = comments[indexPath.item]
        let height = comment.size(forWidth: view.frame.width).height + 70
        
        return height
    }
    
}

// MARK: - UITableViewDelegate

extension CommentVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [unowned self] action, sourceView, completion in
            
            let comment = comments[indexPath.item]
            
            CommentService.deleteComment(postId: post.postId, commentId: comment.commentId) { error, _ in
                if error != nil { fatalError(error.debugDescription) }
                completion(true)
            }
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: K.SystemImageName.trash)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

// MARK: - CommentInputAccesoryViewDelegate

extension CommentVC: CommentInputAccesoryViewDelegate {
    
    func didSubmit(forComment comment: String) {
        showLoader(true)
        
        if comment.isEmpty {
            showLoader(false)
            return
        }
        
        guard let postId = self.post.postId else { return }
        guard let uid = AuthService.shared.getCurrentUserUid() else { return }
        
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let commentId: String = NSUUID().uuidString
        
        let values = [
            K.Comment.uid: uid,
            K.Comment.commentId: commentId,
            K.Comment.commentText: comment,
            K.Comment.creationDate: creationDate
        ] as [String : Any]
        
        COMMENT_REF.child(postId).child(commentId).updateChildValues(values) { [weak self] error, ref in
            guard let self else { return }
            
            self.uploadCommentNotificationToServer()
            
            if comment.contains(K.String.mention) {
                self.uploadMentionNotification(forPostId: postId, withText: comment, isForComment: true)
            }
            
            self.commentInputView.clearCommentTextView()
            
            showLoader(false)
        }
    }
    
}
















