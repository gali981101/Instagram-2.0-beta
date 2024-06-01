//
//  StringFactory.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/22.
//

import UIKit

enum StringFactory {
    
    static func attributedStatText(value: Int, label: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(
            string: "\(value)\n",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
        )
        
        attributedText.append(NSAttributedString(
            string: label,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.lightGray
            ])
        )
        
        return attributedText
    }
    
}
