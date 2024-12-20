//
//  Entities+Extensions.swift
//  DataLayer
//
//  Created by Martin Lukacs on 18/12/2024.
//

import Models

extension TokenData {
    var toEntity: TokenDataEntity {
        TokenDataEntity(id: id,
                        name: name,
                        iconUrl: iconUrl,
                        token: token,
                        folderId: folderId,
                        isFavorite: isFavorite,
                        widgetActivated: widgetActivated,
                        complementaryInfos: complementaryInfos)
    }
}

extension TokenDataEntity {
    var toToken: TokenData {
        TokenData(id: id,
                  name: name,
                  iconUrl: iconUrl,
                  token: token,
                  folderId: folderId,
                  isFavorite: isFavorite,
                  widgetActivated: widgetActivated,
                  complementaryInfos: complementaryInfos)
    }
}

extension [TokenDataEntity] {
    var toTokens: [TokenData] {
        map(\.toToken)
    }
}