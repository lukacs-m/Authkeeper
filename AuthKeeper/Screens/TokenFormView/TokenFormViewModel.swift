//
//
//  TokenFormViewModel.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 14/12/2024.
//
//

import Factory
import Foundation
import Models
import OneTimePassword

extension Generator.Algorithm: @retroactive CaseIterable, @retroactive Identifiable {
    public static var allCases: [Generator.Algorithm] { [.sha1, .sha256, .sha512] }

    public var id: String {
        switch self {
        case .sha1: "sha1"
        case .sha256: "sha256"
        case .sha512: "sha512"
        }
    }
}

@Observable
@MainActor
final class TokenFormViewModel: Sendable {
    var type: OTPType = .totp
    var issuer = ""
    var name = ""
    var account = ""
    var secret = ""
    var period: TimeInterval = 30
    var digits: Int = 6
    var algo: Generator.Algorithm = .sha1
    var includeInFavorite = false
    var includeInWidget = false
    var counter: String = "0"
    var complementaryInformation: String = ""

    var canSave: Bool {
        !issuer.isEmpty && secret.count >= 4
    }

    @ObservationIgnored
    @LazyInjected(\ServiceContainer.tokensDataService) private var tokensDataService

    init(item: TokenData?) {
        setUp(item: item)
    }

    func save() async {
        do {
            guard let secretData = Base32Codec.data(from: secret),
                  !secretData.isEmpty else {
                print("Invalid secret")
                return
            }
            let generator: Generator
            switch type {
            case .totp:
                generator = try Generator(factor: .timer(period: period),
                                          secret: secretData,
                                          algorithm: algo,
                                          digits: digits)

            case .hotp:
                guard let counterNum = Int(counter) else {
                    return
                }
                generator = try Generator(factor: .counter(UInt64(counterNum)),
                                          secret: secretData,
                                          algorithm: algo,
                                          digits: digits)
            }
            let token = Token(generator: generator, name: account, issuer: issuer)
            let tokenData = TokenData(name: name.isEmpty ? nil : name,
                                      token: token,
                                      isFavorite: includeInFavorite,
                                      widgetActivated: includeInWidget,
                                      complementaryInfos: complementaryInformation
                                          .isEmpty ? nil : complementaryInformation)
            await tokensDataService.addToken(token: tokenData)
        } catch {
            print("Error saving token: \(error)")
        }
    }
}

private extension TokenFormViewModel {
    func setUp(item: TokenData?) {
        if let item {
            name = item.name ?? ""
            issuer = item.token.issuer
            account = item.token.name
            secret = Base32Codec.base32String(from: item.token.generator.secret) ?? ""
            period = item.token.generator.factor.period ?? 30
            digits = item.token.generator.digits
            algo = item.token.generator.algorithm
            includeInFavorite = item.isFavorite
            includeInWidget = item.widgetActivated
            complementaryInformation = item.complementaryInfos ?? ""
            if let value = try? item.token.generator.factor.counterValue(at: .now) {
                counter = String("\(value)")
            }
            type = item.type
        }
    }
}
