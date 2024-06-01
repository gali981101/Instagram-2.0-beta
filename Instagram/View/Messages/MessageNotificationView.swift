//
//  MessageNotificationView.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/27.
//

import UIKit

final class MessageNotificationView: UIView {
    
    // MARK: - UIElement
    
    lazy var notificationLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
        
        addSubview(notificationLabel)
        
        notificationLabel.centerX(inView: self)
        notificationLabel.centerY(inView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
