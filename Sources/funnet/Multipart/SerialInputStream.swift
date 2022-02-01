//
//  SerialInputStream.swift
//  PDSLibrary
//
//  Created by Soroush Khanlou on 9/26/19.
//  Copyright © 2019 Project Documents Solutions. All rights reserved.
//

import Foundation

public class SerialInputStream: InputStream {

    public let inputStreams: [InputStream]

    private var currentIndex: Int
    private var _streamStatus: Stream.Status
    private var _streamError: Error?
    private var _delegate: StreamDelegate?

    public init(inputStreams: [InputStream]) {
        self.inputStreams = inputStreams
        self.currentIndex = 0
        self._streamStatus = .notOpen
        self._streamError = nil
        super.init(data: Data()) //required because `init()` is not marked as a designated initializer
    }

    public override var streamStatus: Stream.Status {
        return _streamStatus
    }

    public override var streamError: Error? {
        return _streamError
    }

    public override var delegate: StreamDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
        }
    }

    public override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength: Int) -> Int {
        if _streamStatus == .closed{
            return 0
        }

        var totalNumberOfBytesRead = 0

        while totalNumberOfBytesRead < maxLength {
            if currentIndex == inputStreams.count {
                self.close()
                break
            }

            let currentInputStream = inputStreams[currentIndex]

            if currentInputStream.streamStatus != .open {
                currentInputStream.open()
            }

            if !currentInputStream.hasBytesAvailable {
                self.currentIndex += 1
                continue
            }

            let remainingLength = maxLength - totalNumberOfBytesRead

            let numberOfBytesRead = currentInputStream.read(&buffer[totalNumberOfBytesRead], maxLength: remainingLength)

            if numberOfBytesRead == 0 {
                self.currentIndex += 1
                continue
            }

            if numberOfBytesRead == -1 {
                self._streamError = currentInputStream.streamError
                self._streamStatus = .error
                return -1
            }

            totalNumberOfBytesRead += numberOfBytesRead
        }

        return totalNumberOfBytesRead
    }

    public override func getBuffer(_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>, length len: UnsafeMutablePointer<Int>) -> Bool {
        return false
    }

    public override var hasBytesAvailable: Bool {
        return true
    }

    public override func open() {
        guard self._streamStatus == .open else {
            return
        }
        self._streamStatus = .open
    }

    public override func close() {
        self._streamStatus = .closed
    }

    public override func property(forKey key: Stream.PropertyKey) -> Any? {
        return nil
    }

    public override func setProperty(_ property: Any?, forKey key: Stream.PropertyKey) -> Bool {
        return false
    }

    public override func schedule(in aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {

    }

    public override func remove(from aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {

    }

}
