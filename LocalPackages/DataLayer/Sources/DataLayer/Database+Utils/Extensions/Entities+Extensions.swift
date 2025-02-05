//
//  Entities+Extensions.swift
//  DataLayer
//
//  Created by Martin Lukacs on 18/12/2024.
//

import Foundation
import Models

extension TokenData {
    func toEntity(encryptedData: Data) -> TokenDataEntity {
//        TokenDataEntity(id: id,
//                        name: name,
//                        iconUrl: iconUrl,
//                        token: token,
//                        folderId: folderId,
//                        isFavorite: isFavorite,
//                        widgetActivated: widgetActivated,
//                        complementaryInfos: complementaryInfos,
//                        tags: tags)
        TokenDataEntity(id: id,
                        encryptedData: encryptedData)
    }
}

// extension [TokenData] {
//    func toEntities: [TokenDataEntity] {
//        map(\.toEntity)
//    }
// }

// extension TokenDataEntity {
//    var toToken: TokenData {
//        TokenData(id: id,
//                  name: name,
//                  iconUrl: iconUrl,
//                  token: token,
//                  folderId: folderId,
//                  isFavorite: isFavorite,
//                  widgetActivated: widgetActivated,
//                  complementaryInfos: complementaryInfos,
//                  tags: tags)
//    }
// }
//
// extension [TokenDataEntity] {
//    var toTokens: [TokenData] {
//        map(\.toToken)
//    }
// }
