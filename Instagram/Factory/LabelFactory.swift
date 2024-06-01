//
//  LabelFactory.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/20.
//

import UIKit

enum LabelFactory {
    
    static func makeStatsLabel(number: Int, text: String) -> UILabel {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.textAlignment = .center
        
        label.attributedText = StringFactory.attributedStatText(
            value: number,
            label: text
        )
        
        return label
    }
    
}


