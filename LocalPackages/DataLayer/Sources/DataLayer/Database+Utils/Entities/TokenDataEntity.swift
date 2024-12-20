//
//  TokenDataEntity.swift
//  DataLayer
//
//  Created by Martin Lukacs on 18/12/2024.
//

import Foundation
import OneTimePassword
import SwiftData

@Model
public final class TokenDataEntity: Equatable, Hashable, @unchecked Sendable {
    @Attribute(.unique)
    public private(set) var id: String
    public private(set) var name: String?
    public private(set) var iconUrl: String?
    public private(set) var token: Token
    public private(set) var isFavorite: Bool
    public private(set) var widgetActivated: Bool
    public private(set) var complementaryInfos: String?
    public private(set) var folderId: String?

    init(id: String,
         name: String? = nil,
         iconUrl: String? = nil,
         token: Token,
         folderId: String? = nil,
         isFavorite: Bool,
         widgetActivated: Bool,
         complementaryInfos: String? = nil) {
        self.id = id
        self.name = name
        self.iconUrl = iconUrl
        self.token = token
        self.isFavorite = isFavorite
        self.widgetActivated = widgetActivated
        self.complementaryInfos = complementaryInfos
        self.folderId = folderId
    }
}
