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
        userMessageBackgroundColor: Color = Color.gray.opacity(0.2),
        characterMessageBackgroundColor: Color = Color.gray.opacity(0.1),
        userMessageFont: Font = .system(size: 14, weight: .medium),
        characterMessageFont: Font = .system(size: 14, weight: .medium),
        userMessageTextColor: Color = Color.primary,
        characterMessageTextColor: Color = Color.primary,
        errorMessageFont: Font = .system(size: 14, weight: .medium),
        retryButtonFont: Font = .system(size: 12, weight: .medium),
        retryButtonBackgroundColor: Color = Color.gray,
        retryButtonTextColor: Color = Color.white,
        animatedEllipsisColor: Color = Color.secondary,
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
