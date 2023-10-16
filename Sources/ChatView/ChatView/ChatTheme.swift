//
//  File.swift
//  
//
//  Created by Jim Conroy on 23/9/2023.
//

import SwiftUI

public struct ChatTheme {
    public let userMessageBackgroundColor: Color
    public let characterMessageBackgroundColor: Color
    public let userMessageFont: Font
    public let characterMessageFont: Font
    public let userMessageTextColor: Color
    public let characterMessageTextColor: Color
    public let errorMessageFont: Font
    public let retryButtonFont: Font
    public let retryButtonBackgroundColor: Color
    public let retryButtonTextColor: Color
    public let animatedEllipsisColor: Color
    public let animatedEllipsisSize: CGFloat

    public init(
        userMessageBackgroundColor: Color = Color.gray.opacity(0.2),
        characterMessageBackgroundColor: Color = Color.gray.opacity(0.1),
        userMessageFont: Font = .caption,
        characterMessageFont: Font = .caption,
        userMessageTextColor: Color = Color.primary,
        characterMessageTextColor: Color = Color.primary,
        errorMessageFont: Font = .caption,
        retryButtonFont: Font = .caption,
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
