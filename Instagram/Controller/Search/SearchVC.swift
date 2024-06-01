//
//  SearchVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/17.
//

import UIKit

private let searchUserCellId = K.CellId.searchUserCell
private let searchPostCellId = K.CellId.searchPostCell

// MARK: - SearchVC

final class SearchVC: UIViewController {
    
    // MARK: - Properties
    
    var currentKey: String?
    var userCurrentKey: String?
    
    private lazy var posts: [Post] = []
    private lazy var users: [User] = []
    private lazy var filteredUsers: [User] = []
    
    private lazy var inSearchMode: Bool = false
    private lazy var isFirstLoad: Bool = true
    
    // MARK: - UIElement
    
    private lazy var tableView: UITableView = UITableView()
    private lazy var searchBar: UISearchBar = UISearchBar()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.dataSource = self
        cv.delegate = self
        
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .systemBackground
        
        cv.register(SearchPostCell.self, forCellWithReuseIdentifier: searchPostCellId)
        
        return cv
    }()
    
    private lazy var refresher = UIRefreshControl()
    
    // MARK: - init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        fetchUsers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension SearchVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstLoad {
            handleRefresh()
            isFirstLoad = false
        }
    }
    
}

// MARK: - Set Up

extension SearchVC {
    
    private func config() {
        configureSearchBar()
        configureCollectionView()
        configureTableView()
        configureGesture()
    }
    
}

// MARK: - @objc Actions

extension SearchVC {
    
    @objc private func handleRefresh()  {
        posts.removeAll(keepingCapacity: false)
        collectionView.reloadData()
        self.currentKey = nil
        fetchPosts()
    }
    
    @objc private func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: tableView)
        
        if let _ = tableView.indexPathForRow(at: location) {
            // 如果點擊位置位於 tableView cell 上，則不取消 searchBar
            return
        }
        
        // 如果點擊位置不位於 tableView cell 上，則取消 searchBar
        searchBar.resignFirstResponder()
        
        addCollectionView()
    }
    
}

// MARK: - Service

extension SearchVC {
    
    private func fetchPosts() {
        if currentKey == nil {
            showLoader(true)
            endRefresher()
            loadRecentPosts()
        } else {
            loadOldPosts()
        }
    }
    
    private func fetchUsers() {
        if userCurrentKey == nil {
            loadRecentUsers()
        } else {
            loadOldUsers()
        }
    }
    
}

// MARK: - Handlers

extension SearchVC {
    
    private func loadRecentPosts() {
        PostService.fetchCurrentPosts(limit: 21, vc: self) { [weak self] first, objects in
            guard let self else { return }
            
            objects.forEach { snapshot in
                let postId = snapshot.key
                self.fetchPost(withPostId: postId)
            }
            
            self.currentKey = first.key
            showLoader(false)
        }
    }
    
    private func loadOldPosts() {
        PostService.fetchCurrentPosts(limit: 10, vc: self) { [weak self] first, objects in
            guard let self else { return }
            
            objects.forEach { snapshot in
                let postId = snapshot.key
                if postId != self.currentKey { self.fetchPost(withPostId: postId) }
            }
            
            self.currentKey = first.key
            showLoader(false)
        }
    }
    
    private func loadRecentUsers() {
        UserService.fetchCurrentUsers(limit: 10) { [weak self] user, key in
            DispatchQueue.main.async {
                guard let self else { return }
                self.users.append(user)
                self.tableView.reloadData()
                self.userCurrentKey = key
            }
        }
    }
    
    private func loadOldUsers() {
        UserService.fetchOldUsers(userCurrentKey) { [weak self] user, objectsCount, key in
            DispatchQueue.main.async {
                guard let self else { return }
                self.users.append(user)
                if self.users.count == objectsCount { self.tableView.reloadData() }
                self.currentKey = key
            }
        }
    }
    
    private func fetchPost(withPostId postId: String) {
        PostService.fetchPost(with: postId) { [weak self] post in
            guard let self else { return }
            
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

// MARK: - Helper Methods

extension SearchVC {
    
    private func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.barTintColor = .systemBackground
        searchBar.tintColor = .label
        
        navigationItem.titleView = searchBar
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.fillSuperview()
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: searchUserCellId)
        tableView.rowHeight = 64
        
        tableView.separatorStyle = .none
        tableView.fillSuperview()
    }
    
    private func configureGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapGestureHandler(_:))
        )
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func addCollectionView() {
        view.addSubview(collectionView)
        collectionView.fillSuperview()
        
        tableView.removeFromSuperview()
    }
    
    private func addTableView() {
        fetchUsers()
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        tableView.reloadData()
        
        collectionView.removeFromSuperview()
    }
    
    private func filterUsers(searchText: String) {
        var users1: [User] = []
        var users2: [User] = []
        var users3: [User] = []
        
        for user in self.users {
            if user.username.contains(searchText) { users1.append(user) }
        }
        
        for user in self.users {
            if user.fullname.contains(searchText) { users2.append(user) }
        }
        
        users3 = users1 + users2
        
        for i in 0..<users1.count {
            for j in 0..<users2.count {
                if users1[i].uid == users2[j].uid { users3.remove(at: i) }
            }
        }
        
        filteredUsers = users3
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

// MARK: - UICollectionViewDataSource

extension SearchVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: searchPostCellId, for: indexPath) as! SearchPostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension SearchVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (posts.count > 20) && (indexPath.item == posts.count - 1) { fetchPosts() }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedVC(post: posts[indexPath.item], viewSinglePost: true)
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
}

// MARK: - UITableViewDataSource

extension SearchVC: UITableViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredUsers.count
        } else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchUserCellId, for: indexPath) as! SearchUserCell
        
        var user: User!
        
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        cell.user = user
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension SearchVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (users.count > 3) && (indexPath.item == users.count - 1) { fetchUsers() }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var user: User!
        
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        
        inSearchMode = false
        
        let userProfileVC = UserProfileVC(user: user)
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        addTableView()
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchText = searchText.lowercased()
        
        if searchText.isEmpty || searchText == K.String.oneSpace {
            inSearchMode = false
            tableView.reloadData()
        } else {
            inSearchMode = true
            filterUsers(searchText: searchText)
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        
        inSearchMode = false
        
        addCollectionView()
        tableView.reloadData()
    }
    
}

