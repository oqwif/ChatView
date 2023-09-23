//
//  File.swift
//  
//
//  Created by Jim Conroy on 23/9/2023.
//

import SwiftUI

public struct ChatTheme {
    public var userMessageBackgroundColor: Color
    public var characterMessageBackgroundColor: Color
    public var userMessageFont: Font
    public var characterMessageFont: Font
    public var userMessageTextColor: Color
    public var characterMessageTextColor: Color
    public var errorMessageFont: Font
    public var retryButtonFont: Font
    public var retryButtonBackgroundColor: Color
    public var retryButtonTextColor: Color
    public var animatedEllipsisColor: Color
    public var animatedEllipsisSize: CGFloat

    public init(
        userMessageBackgroundColor: Color = Color(UIColor.systemGray4),
        characterMessageBackgroundColor: Color = Color(UIColor.systemGray6),
        userMessageFont: Font = .system(size: 14, weight: .medium),
        characterMessageFont: Font = .system(size: 14, weight: .medium),
        userMessageTextColor: Color = Color(UIColor.label),
        characterMessageTextColor: Color = Color(UIColor.label),
        errorMessageFont: Font = .system(size: 14, weight: .medium),
        retryButtonFont: Font = .system(size: 12, weight: .medium),
        retryButtonBackgroundColor: Color = Color(UIColor.systemGray),
        retryButtonTextColor: Color = Color(UIColor.white),
        animatedEllipsisColor: Color = Color(UIColor.systemGray2),
        animatedEllipsisSize: CGFloat = 6.0
    ) {
        self.userMessageBackgroundColor = userMessageBackgroundColor
        self.characterMessageBackgroundColor = characterMessageBackgroundColor
        self.userMessageFont = userMessageFont
        self.characterMessageFont = characterMessageFont
        self.userMessageTextColor = userMessageTextColor
        self.characterMessageTextColor = characterMessageTextColor
        self.errorMessageFont = errorMessageFont
        self.retryButtonFont = retryButtonFont
        self.retryButtonBackgroundColor = retryButtonBackgroundColor
        self.retryButtonTextColor = retryButtonTextColor
        self.animatedEllipsisColor = animatedEllipsisColor
        self.animatedEllipsisSize = animatedEllipsisSize
    }
}
