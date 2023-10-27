//
//  File.swift
//  
//
//  Created by Jim Conroy on 27/10/2023.
//

import Foundation

public protocol OpenAISystemMessageProvider {
    var systemMessage: String { get }
}
