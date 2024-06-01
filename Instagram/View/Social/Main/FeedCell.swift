//
//  FeedCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/15.
//

import UIKit
import SDWebImage
import ActiveLabel

private let postImageCellId = K.CellId.postImageCell

// MARK: - FeedCell

final class FeedCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: FeedCellDelegate?
    
    var viewSinglePost: Bool?
    
    var post: Post? { didSet { config() } }
    
    private lazy var imageUrls: [String] = []
    
    // MARK: - UIElement
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle(K.ButtonTitle.username, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.addTarget(self, action: #selector(handleUsernameTapped) , for: .touchUpInside)
        
        return button
    }()
    
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle(K.ButtonTitle.threeDots, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.addTarget(self, action: #selector(handleOptionsTapped) , for: .touchUpInside)
        
        return button
    }()
    
    lazy var postImageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        cv.dataSource = self
        cv.delegate = self
        
        cv.register(PostImageCell.self, forCellWithReuseIdentifier: postImageCellId)
        
        cv.backgroundColor = .systemBackground
        
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapToLike))
        likeTap.numberOfTapsRequired = 2
        
        cv.isUserInteractionEnabled = true
        cv.addGestureRecognizer(likeTap)
        
        return cv
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        
        control.pageIndicatorTintColor = .gray.withAlphaComponent(0.5)
        control.currentPageIndicatorTintColor = .systemBlue
        control.currentPage = 0
        
        control.addTarget(self, action: #selector(handleChangePage), for: .valueChanged)
        
        return control
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: K.SystemImageName.heart)
        
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(handleLikeTapped) , for: .touchUpInside)
        
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: K.SystemImageName.message)
        
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(handleCommentTapped) , for: .touchUpInside)
        
        return button
    }()
    
    private lazy var messageButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: K.SystemImageName.paperplane)
        
        button.setImage(image, for: .normal)
        button.tintColor = .label
        
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            likeButton,
            commentButton,
            messageButton]
        )
        
        view.axis = .horizontal
        view.distribution = .fillEqually
        
        return view
    }()
    
    private lazy var savePostButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: K.SystemImageName.bookmark)
        
        button.setImage(image, for: .normal)
        button.tintColor = .label
        
        return button
    }()
    
    lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = K.LabelText.likesnum
        
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
        
        likeTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likeTap)
        
        return label
    }()
    
    lazy var captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        
        label.numberOfLines = 3
        
        let captionTap = UITapGestureRecognizer(target: self, action: #selector(handleCaptionTapped))
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(captionTap)
        
        return label
    }()
    
    private lazy var postTimeLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = K.LabelText.postTime
        
        return label
    }()
    
    lazy var commentIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set Up

extension FeedCell {
    
    private func style() {
        backgroundColor = .systemBackground
        
        addSubview(profileImageView)
        addSubview(usernameButton)
        addSubview(optionsButton)
        addSubview(postImageCollectionView)
        addSubview(pageControl)
        addSubview(stackView)
        addSubview(savePostButton)
        addSubview(likesLabel)
        addSubview(captionLabel)
        addSubview(postTimeLabel)
    }
    
    private func layout() {
        profileImageView.layer.cornerRadius = 40 / 2
        profileImageView.setDimensions(height: 40, width: 40)
        
        profileImageView.anchor(
            top: topAnchor,
            left: leftAnchor,
            paddingTop: 12,
            paddingLeft: 12
        )
        
        usernameButton.centerY(
            inView: profileImageView,
            leftAnchor: profileImageView.rightAnchor,
            paddingLeft: 8
        )
        
        optionsButton.centerY(inView: usernameButton)
        
        optionsButton.anchor(
            right: rightAnchor,
            paddingRight: 12
        )
        
        postImageCollectionView.anchor(
            top: profileImageView.bottomAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: 8
        )
        
        postImageCollectionView.heightAnchor.constraint(
            equalTo: widthAnchor,
            multiplier: 1
        ).isActive = true
        
        stackView.anchor(
            top: postImageCollectionView.bottomAnchor,
            left: leftAnchor,
            paddingLeft: 8,
            width: 120,
            height: 50
        )
        
        pageControl.centerY(inView: stackView)
        pageControl.centerX(inView: self)
        
        pageControl.setWidth(135)
        
        for dot in pageControl.subviews {
            dot.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        }
        
        savePostButton.centerY(inView: stackView)
        
        savePostButton.anchor(
            right: rightAnchor,
            paddingRight: 20
        )
        
        likesLabel.anchor(
            top: likeButton.bottomAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: -4,
            paddingLeft: 16,
            paddingRight: 16
        )
        
        captionLabel.anchor(
            top: likesLabel.bottomAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: 8,
            paddingLeft: 16,
            paddingRight: 16
        )
        
        postTimeLabel.anchor(
            top: captionLabel.bottomAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: 8,
            paddingLeft: 16,
            paddingRight: 16
        )
    }
    
}


// MARK: - @objc Actions

extension FeedCell {
    
    @objc private func handleUsernameTapped() {
        delegate?.handleUsernameTapped(for: self)
    }
    
    @objc private func handleOptionsTapped() {
        delegate?.handleOptionsTapped(for: self)
    }
    
    @objc private func handleLikeTapped() {
        delegate?.handleLikeTapped(for: self, isDoubleTap: false)
    }
    
    @objc private func handleCaptionTapped() {
        delegate?.handleCaptionsTapped(for: self)
    }
    
    @objc private func handleCommentTapped() {
        delegate?.handleCommentTapped(for: self)
    }
    
    @objc private func handleShowLikes() {
        delegate?.handleShowLikes(for: self)
    }
    
    @objc private func handleDoubleTapToLike() {
        delegate?.handleLikeTapped(for: self, isDoubleTap: true)
    }
    
    @objc private func handleChangePage(sender: AnyObject) {
        let x = CGFloat(pageControl.currentPage) * postImageCollectionView.frame.size.width
        postImageCollectionView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
}

// MARK: - Configure

extension FeedCell {
    
    private func config() {
        guard let ownerUid = post?.ownerUid else { return }
        guard let imageUrls = post?.imageUrls else { return }
        guard let likes = post?.likes else { return }
        
        UserService.fetchUserData(with: ownerUid) { [weak self] user in
            guard let self else { return }
            let url = URL(string: user.profileImageUrl)
            
            self.profileImageView.sd_setImage(with: url)
            self.usernameButton.setTitle(user.username, for: .normal)
            self.configurePostCaption(user: user)
        }
        
        
        self.imageUrls = imageUrls
        postImageCollectionView.reloadData()
        
        let firstItemIndexPath = IndexPath(item: 0, section: 0)
        postImageCollectionView.scrollToItem(at: firstItemIndexPath, at: .left, animated: true)
        
        if imageUrls.count == 1 {
            pageControl.numberOfPages = 0
        } else {
            pageControl.numberOfPages = imageUrls.count
            pageControl.currentPage = 0
        }
        
        likesLabel.text = "\(likes) \(K.Post.likes)"
        
        configureLikeButton()
        configureCommentIndicatorView()
    }
    
}

// MARK: - Handlers

extension FeedCell {
    
    private func configureLikeButton() {
        delegate?.handleConfigureLikeButton(for: self)
    }
    
    private func configureCommentIndicatorView() {
        delegate?.configureCommentIndicatorView(for: self)
    }
    
    private func configurePostCaption(user: User) {
        guard let post = self.post else { return }
        guard let caption = post.caption else { return }
        guard let username = post.user?.username else { return }
        
        // look for username as pattern
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        // enable username as custom type
        captionLabel.enabledTypes = [.mention, .hashtag, .url, customType]
        
        // configure usnerame link attributes
        captionLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 14)
            default: ()
            }
            return atts
        }
        
        captionLabel.customize { (label) in
            label.text = "\(username) \(caption)"
            label.customColor[customType] = .label
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .label
            
            if let viewSinglePost = viewSinglePost, viewSinglePost {
                captionLabel.numberOfLines = 0
            } else {
                captionLabel.numberOfLines = 4
            }
        }
        
        postTimeLabel.text = post.creationDate.timeAgoToDisplay()
    }
    
    func addCommentIndicatorView(toStackView stackView: UIStackView) {
        stackView.addSubview(commentIndicatorView)
        
        commentIndicatorView.isHidden = false
        commentIndicatorView.layer.cornerRadius = 10 / 2
        
        commentIndicatorView.setDimensions(height: 10, width: 10)
        
        commentIndicatorView.anchor(
            top: stackView.topAnchor,
            left: stackView.leftAnchor,
            paddingTop: 14,
            paddingLeft: 64
        )
    }
    
}

// MARK: - UICollectionViewDataSource

extension FeedCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCellId, for: indexPath) as! PostImageCell
        
        let url = URL(string: imageUrls[indexPath.item])
        cell.postImageView.sd_setImage(with: url)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension FeedCell: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.width
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
}

