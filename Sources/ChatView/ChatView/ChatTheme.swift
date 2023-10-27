//
//  File.swift
//  
//
//  Created by Jamie Conroy on 23/9/2023.
//

import SwiftUI

/**
 `ChatTheme` is a struct that encapsulates the appearance settings for a `ChatView`. It provides a way to customize the look and feel of the chat interface.

 The struct contains several properties that determine the appearance of various elements of the chat interface:
 - `userMessageBackgroundColor`: The background color of user messages.
 - `characterMessageBackgroundColor`: The background color of character messages.
 - `userMessageFont`: The font of user messages.
 - `characterMessageFont`: The font of character messages.
 - `userMessageTextColor`: The text color of user messages.
 - `characterMessageTextColor`: The text color of character messages.
 - `errorMessageFont`: The font of error messages.
 - `retryButtonFont`: The font of the retry button.
 - `retryButtonBackgroundColor`: The background color of the retry button.
 - `retryButtonTextColor`: The text color of the retry button.
 - `animatedEllipsisColor`: The color of the animated ellipsis.
 - `animatedEllipsisSize`: The size of the animated ellipsis.

 The struct provides an initializer that allows all of these properties to be set. If no values are provided, default values are used.
 */
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
        userMessageFont: Font = .callout,
        characterMessageFont: Font = .callout,
        userMessageTextColor: Color = Color.primary,
        characterMessageTextColor: Color = Color.primary,
        errorMessageFont: Font = .callout,
        retryButtonFont: Font = .callout,
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
