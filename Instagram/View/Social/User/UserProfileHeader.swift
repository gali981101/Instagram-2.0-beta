//
//  UserProfileHeader.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/15.
//

import UIKit

private let topDivider: UIView = UIView()

// MARK: - UserProfileHeader

final class UserProfileHeader: UICollectionViewCell {
     
    // MARK: - Properties
    
    weak var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            configureEditProfileFollowButton()
            
            setUserStats(for: user)
            
            let fullName = user?.fullname
            nameLabel.text = fullName
            
            guard let profileImageUrl = user?.profileImageUrl else { return }
            
            let url = URL(string: profileImageUrl)
            profileImageView.sd_setImage(with: url)
        }
    }
    
    // MARK: - UIElement
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var postsLabel: UILabel = {
        let label = LabelFactory.makeStatsLabel(
            number: 5,
            text: K.AttributedString.posts
        )
        return label
    }()
    
    lazy var followersLabel: UILabel = {
        let label = LabelFactory.makeStatsLabel(
            number: 0,
            text: K.AttributedString.followers
        )
        
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        followTap.numberOfTapsRequired = 1
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        
        return label
    }()
    
    lazy var followingLabel: UILabel = {
        let label = LabelFactory.makeStatsLabel(
            number: 0,
            text: K.AttributedString.following
        )
        
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        followTap.numberOfTapsRequired = 1
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            postsLabel,
            followersLabel,
            followingLabel
        ])
        
        view.axis = .horizontal
        view.distribution = .fillEqually
        
        return view
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle(K.ButtonTitle.loading, for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: K.SystemImageName.gridFill)
        
        button.setImage(image, for: .normal)
        button.tintColor = .label
        
        button.addTarget(self, action: #selector(handleGridTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var personSquareButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: K.SystemImageName.personSquare)
        
        button.setImage(image, for: .normal)
        button.tintColor = .label
        
        button.addTarget(self, action: #selector(handlePersonSquareTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var gridSquareButtonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            gridButton,
            personSquareButton
        ])
        
        view.axis = .horizontal
        view.distribution = .fillEqually
        
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

// MARK: - Set up

extension UserProfileHeader {
    
    private func style() {
        backgroundColor = .systemBackground
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(labelStackView)
        addSubview(editProfileFollowButton)
        addSubview(topDivider)
        addSubview(gridSquareButtonStackView)
        
        profileImageView.layer.cornerRadius = 80 / 2
        
        topDivider.backgroundColor = .lightGray
        
        setAlpha(for: gridButton)
    }
    
    private func layout() {
        profileImageView.anchor(
            top: topAnchor,
            left: leftAnchor,
            paddingTop: 16,
            paddingLeft: 30
        )
        
        profileImageView.setDimensions(height: 80, width: 80)
        
        nameLabel.anchor(
            top: profileImageView.bottomAnchor,
            left: leftAnchor,
            paddingTop: 12,
            paddingLeft: 30
        )
        
        labelStackView.centerY(inView: profileImageView)
        
        labelStackView.anchor(
            left: profileImageView.rightAnchor,
            right: rightAnchor,
            paddingLeft: 12,
            paddingRight: 12,
            height: 50
        )
        
        editProfileFollowButton.anchor(
            left: postsLabel.leftAnchor,
            right: rightAnchor,
            paddingLeft: 24,
            paddingRight: 24,
            height: 30
        )
        
        editProfileFollowButton.centerY(inView: nameLabel)
        
        topDivider.anchor(
            top: gridSquareButtonStackView.topAnchor,
            left: leftAnchor,
            right: rightAnchor,
            height: 0.5
        )
        
        gridSquareButtonStackView.anchor(
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor,
            height: 50
        )
    }
    
}

// MARK: - @objc Actions

extension UserProfileHeader {
    
    @objc private func handleFollowersTapped() {
        delegate?.handleFollowersTapped(for: self)
    }
    
    @objc private func handleFollowingTapped() {
        delegate?.handleFollowingTapped(for: self)
    }
    
    @objc private func handleEditProfileFollow() {
        delegate?.handleEditFollowTapped(for: self)
    }
    
    @objc private func handleGridTapped() {
        setAlpha(for: gridButton)
        updateGridButton()
    }
    
    @objc private func handlePersonSquareTapped() {
        setAlpha(for: personSquareButton)
        updatePersonSquareButton()
    }
    
}

// MARK: - Handlers 

extension UserProfileHeader {
    
    private func configureEditProfileFollowButton() {
        guard let currentUid = AuthService.shared.getCurrentUserUid() else { return }
        guard let user = self.user else { return }
        
        if currentUid == user.uid {
            editProfileFollowButton.setTitle(K.ButtonTitle.editProfile, for: .normal)
        } else {
            editProfileFollowButton.setTitleColor(.white, for: .normal)
            editProfileFollowButton.backgroundColor = .systemBlue
            
            user.checkIfUserIsFollowed() { [weak self] followed in
                guard let self else { return }
                self.editProfileFollowButton.setTitle(followed ? K.FollowStats.following : K.FollowStats.follow, for: .normal)
            }
        }
    }
    
}

// MARK: - Helper Methods

extension UserProfileHeader {
    
    private func setUserStats(for user: User?) {
        delegate?.setUserStats(for: self)
    }
    
    private func setAlpha(for button: UIButton) {
        gridButton.alpha = 0.5
        personSquareButton.alpha = 0.5
        
        button.alpha = 1.0
    }
    
    private func updateGridButton() {
        gridButton.setImage(
            UIImage(systemName: K.SystemImageName.gridFill),
            for: .normal
        )
        
        personSquareButton.setImage(
            UIImage(systemName: K.SystemImageName.personSquare),
            for: .normal
        )
    }
    
    private func updatePersonSquareButton() {
        personSquareButton.setImage(
            UIImage(systemName: K.SystemImageName.personSquareFill),
            for: .normal
        )
        
        gridButton.setImage(
            UIImage(systemName: K.SystemImageName.gridSplit),
            for: .normal
        )
    }
    
}
