//
//  Tags.swift
//  Models
//
//  Created by martin on 23/01/2025.
//

public enum Tag: Identifiable, Equatable, Hashable, Codable, Sendable, Comparable {
    case all
    case custom(String)

    public var title: String {
        switch self {
        case .all:
            "All"
        case let .custom(title):
            title
        }
    }

    public var id: Int { hashValue }
}
