//
//  SearchUserCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/21.
//

import UIKit

final class SearchUserCell: UITableViewCell {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            guard let username = user?.username else { return }
            guard let fullname = user?.fullname else { return }
            
            let url = URL(string: profileImageUrl)
            
            profileImageView.sd_setImage(with: url)
            usernameLabel.text = username
            fullnameLabel.text = fullname
        }
    }
    
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
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        config()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set Up

extension SearchUserCell {
    
    private func config() {
        self.selectionStyle = .none
        
        addSubview(profileImageView)
        addSubview(stackView)
        
        profileImageView.layer.cornerRadius = 48 / 2
    }
    
    private func layout() {
        profileImageView.setDimensions(height: 48, width: 48)
        
        profileImageView.centerY(
            inView: self,
            leftAnchor: leftAnchor,
            paddingLeft: 12
        )
        
        stackView.centerY(
            inView: profileImageView,
            leftAnchor: profileImageView.rightAnchor,
            paddingLeft: 8
        )
    }
    
}








