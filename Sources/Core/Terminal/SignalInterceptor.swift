//
//  SignalInterceptor.swift
//  Core

import Foundation

/// A type dedicated to intercept UNIX-based systems signals.
struct SignalInterceptor {
    private let source: DispatchSourceSignal
    
    init(signal: Signal = .SIGWINCH) {
        self.source = DispatchSource.makeSignalSource(signal: signal.rawValue)
    }
    /// A container type for the signals needed to be intercepted
    enum Signal: Int32 {
      case HUP    = 1
      case sINT    = 2
      case QUIT   = 3
      case ABRT   = 6
      case KILL   = 9
      case ALRM   = 14
      case TERM   = 15
      case SIGWINCH = 28
    }


    func intercept(action: @escaping() -> Void) {
        source.setEventHandler {
            action()
        }
        source.resume()
    }
}

