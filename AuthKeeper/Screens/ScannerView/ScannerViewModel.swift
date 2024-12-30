//
//
//  ScannerViewModel.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 21/12/2024.
//
//

#if os(iOS)
import DataLayer
import DocScanner
import Factory
import Foundation
import OneTimePassword

@Observable @MainActor
final class ScannerViewModel: Sendable {
    var scanning = true

    @ObservationIgnored
    @LazyInjected(\ServiceContainer.tokensDataService) private var tokensDataService

    private var task: Task<Void, Never>?
    private var hasPayload: Bool = false

    init() {
        setUp()
    }

    func processPayload(results: Result<ScanResult?, Error>) {
        task?.cancel()
        task = Task {
            switch results {
            case let .success(result):
                guard let barcode = result as? Barcode, !hasPayload else { return }
                hasPayload = true
                do {
                    try await tokensDataService.generateAndAddToken(from: barcode.payload)
                } catch {
                    print(error.localizedDescription)
                }
            case let .failure(error):
                print("Error: \(error)")
            }
        }
    }
}

private extension ScannerViewModel {
    func setUp() {}
}
#endif
