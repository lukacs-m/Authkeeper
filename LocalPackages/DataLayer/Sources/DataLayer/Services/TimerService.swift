//
//  TimerService.swift
//  DataLayer
//
//  Created by Martin Lukacs on 02/01/2025.
//

import Combine
import SwiftUI

public protocol TimerServicing {
    var timer: Timer.TimerPublisher { get }
}

public final class TimerService: TimerServicing {
    public let timer: Timer.TimerPublisher
    private let cancellable: AnyCancellable?

    public init(timer: Timer.TimerPublisher = Timer.TimerPublisher(interval: 0.1,
                                                                   runLoop: .main,
                                                                   mode: .default)) {
        self.timer = timer
        cancellable = timer.connect() as? AnyCancellable
    }

    deinit {
        cancellable?.cancel()
    }
}
