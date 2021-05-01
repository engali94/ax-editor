//
//  EventReader.swift
//  Core

import Dispatch
import Foundation

public final class EventReader {
    private let parser: EventParser
    /// Buffer to hold the biggest possible response from the input stream.
    private var buffer: [UInt8] = []
    /// A varaible to represent the reading buffer size. The numer 250 is
    /// chosen according to the biggest ANSI sequence response.
    private let bufferSize = 256

    init(parser: EventParser) {
        self.parser = parser
    }

    /// It allows you to check if there is or isn't an `Event` available within the given period
    /// of time. In other words - if subsequent call to the `read` function will block or not.
    /// - Parameter timeout: maximum waiting time for event availability.
    /// - Returns: `true` if an `Event`  is available otherwise it returns `false`.
    public func poll(timeout: Timeout) -> Bool {
        var fds = [pollfd(fd: STDIN_FILENO, events: Int16(POLLIN), revents: 0)]
        return Darwin.poll(&fds, UInt32(fds.count), Int32(timeout.value)) > 0
    }

    /// Reads a single `Event` from the stdin. This function blocks until an `Event`
    /// is available. Combine it with the `poll`  function to get non-blocking reads.
    /// - Returns: Returns  `.success(Event)` if an `Event`  is available otherwise
    ///   it returns `.failure(Error)``
    /// - seeAlso: `poll`
    public func readBuffer() -> Result<Event, Error> {
        //sigaction(2, 1, 2)
        var chars: [UInt8] = Array(repeating: 0, count: bufferSize)
        let readCount = read(STDIN_FILENO, &chars, bufferSize)
        if readCount != -1 {
            buffer.append(contentsOf: chars)
        } else {
            let error = NSError(domain: POSIXError.errorDomain, code: Int(errno))
            print(error)
            return .failure(error)
        }

        buffer = Array(buffer[0..<readCount])
        return .success(parser.parse(buffer: &buffer) ?? .key(.init(code: .undefined)))
    }

}
