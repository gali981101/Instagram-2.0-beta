//
//  SearchPostCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/21.
//

import UIKit

final class SearchPostCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            guard let imageStringUrl = post?.imageUrls.first else { return }
            guard let imageUrl = URL(string: imageStringUrl) else { return }
            
            postImageView.sd_setImage(with: imageUrl)
        }
    }
    
    lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
