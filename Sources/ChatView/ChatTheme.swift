//
//  File.swift
//  
//
//  Created by Jim Conroy on 23/9/2023.
//

import SwiftUI

public struct ChatTheme {
    var userMessageBackgroundColor: Color = Color(UIColor.systemGray4)
    var characterMessageBackgroundColor: Color = Color(UIColor.systemGray6)
    var userMessageFont: Font = .system(size: 14, weight: .medium)
    var characterMessageFont: Font = .system(size: 14, weight: .medium)
    var userMessageTextColor: Color = Color(UIColor.label)
    var characterMessageTextColor: Color = Color(UIColor.label)
    var errorMessageFont: Font = .system(size: 14, weight: .medium)
    var retryButtonFont: Font = .system(size: 12, weight: .medium)
    var retryButtonBackgroundColor: Color = Color(UIColor.systemGray)
    var retryButtonTextColor: Color = Color(UIColor.white)
    var animatedEllipsisColor: Color = Color(UIColor.systemGray2)
    var animatedEllipsisSize: CGFloat = 6.0
}
