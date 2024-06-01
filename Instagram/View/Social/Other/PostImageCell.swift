//
//  UploadImageCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/24.
//

import UIKit

final class PostImageCell: UICollectionViewCell {
    
    // MARK: - UIElement
    
    lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
