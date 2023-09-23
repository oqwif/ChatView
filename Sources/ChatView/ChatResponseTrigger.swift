//
//  ChatResponseTrigger.swift
//
//  Created by Jim Conroy on 22/9/2023.
//

import Foundation

protocol ChatResponseTrigger {
    func shouldActivate(forChatResponse response: String) -> Bool
    func activate()
}