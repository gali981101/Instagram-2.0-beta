//
//  CommentCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/28.
//

import UIKit
import ActiveLabel

final class CommentCell: UITableViewCell {
    
    // MARK: - Properties
    
    var comment: Comment? { didSet{ configure() } }
    
    // MARK: - UIElement
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    lazy var commentLabel: ActiveLabel = {
        let label = ActiveLabel()
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var commentDateLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var commentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            commentLabel,
            commentDateLabel
        ])
        
        view.axis = .vertical
        view.spacing = 8
        
        return view
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

extension CommentCell {
    
    private func configUI() {
        self.selectionStyle = .none
        
        addSubview(profileImageView)
        addSubview(commentStackView)
        
        profileImageView.layer.cornerRadius = 35 / 2
        profileImageView.setDimensions(height: 35, width: 35)
        
        profileImageView.anchor(
            top: topAnchor,
            left: leftAnchor,
            paddingTop: 12,
            paddingLeft: 8
        )
        
        commentStackView.anchor(
            top: topAnchor,
            left: profileImageView.rightAnchor,
            right: rightAnchor,
            paddingTop: 12,
            paddingLeft: 12,
            paddingRight: 30
        )
    }
    
    private func configure() {
        guard let user = comment?.user else { return }
        guard let profileImageUrl = user.profileImageUrl else { return }
        
        if let url = URL(string: profileImageUrl) {
            profileImageView.sd_setImage(with: url)
        }
        
        configureCommentLabel()
    }
    
    private func configureCommentLabel() {
        guard let comment = self.comment else { return }
        guard let user = comment.user else { return }
        guard let username = user.username else { return }
        guard let commentText = comment.commentText else { return }
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        commentLabel.enabledTypes = [.hashtag, .mention, .url, customType]
        
        commentLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 14)
            default: ()
            }
            return atts
        }
        
        commentLabel.customize { (label) in
            label.text = "\(username) \(commentText)"
            label.customColor[customType] = .label
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .label
            label.numberOfLines = 0
        }
        
        commentDateLabel.text = getCommentTimeStamp()
        commentDateLabel.textColor = .lightGray
    }
    
}

// MARK: - Helper Methods

extension CommentCell {
    
    private func getCommentTimeStamp() -> String? {
        
        guard let comment = self.comment else { return nil }
        
        let now = Date()
        let dateFormatter = DateComponentsFormatter()
        
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        
        return dateFormatter.string(from: comment.creationDate, to: now)
    }
    
}





