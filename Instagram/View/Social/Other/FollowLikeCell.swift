//
//  FollowLikeCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/15.
//

import UIKit

final class FollowLikeCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: FollowCellDelegate?
    
    var user: User? { didSet { configure() } }
    
    // MARK: - UIElement
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = K.LabelText.username
        
        return label
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = K.LabelText.fullname
        label.textColor = .lightGray
        
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            usernameLabel,
            fullnameLabel
        ])
        
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 4
        
        return view
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle(K.ButtonTitle.loading, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        
        return button
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

extension FollowLikeCell {
    
    private func configUI() {
        addSubview(profileImageView)
        addSubview(stackView)
        addSubview(followButton)
        
        profileImageView.layer.cornerRadius = 48 / 2
        followButton.layer.cornerRadius = 3
        
        profileImageView.centerY(inView: self)
        followButton.centerY(inView: self)
        
        profileImageView.setDimensions(height: 48, width: 48)
        followButton.setDimensions(height: 30, width: 90)
        
        profileImageView.anchor(left: leftAnchor, paddingLeft: 8)
        followButton.anchor(right: rightAnchor, paddingRight: 12)
        
        self.selectionStyle = .none
        self.contentView.isUserInteractionEnabled = false
        
        stackView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
    }
    
}

// MARK: - @objc Actions

extension FollowLikeCell {
    
    @objc private func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
}

// MARK: - Helper Methods

extension FollowLikeCell {
    
    private func configure() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        guard let username = user?.username else { return }
        guard let fullname = user?.fullname else { return }
        
        let url = URL(string: profileImageUrl)
        
        profileImageView.sd_setImage(with: url)
        
        usernameLabel.text = username
        fullnameLabel.text = fullname
        
        if user?.uid == AuthService.shared.getCurrentUserUid() {
            followButton.isHidden = true
        }
        
        user?.checkIfUserIsFollowed() { followed in
            self.followButton.configure(didFollow: followed)
        }
    }
    
}
