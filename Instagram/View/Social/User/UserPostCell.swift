//
//  UserPostCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/19.
//

import UIKit

final class UserPostCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrls.first else { return }
            let url = URL(string: imageUrl)
            postImageView.sd_setImage(with: url)
        }
    }
    
    // MARK: - UIElement
    
    lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set Up

extension UserPostCell {
    
    private func configUI() {
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
}
