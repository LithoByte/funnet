//
//  URLLoadingErrorHandler.swift
//  FunNet
//
//  Created by Elliot Schrock on 5/11/21.
//

import Foundation

let urlLoadingErrorCodesDict: [Int: String] = [
    -1000: "Bad URL.",
    -1001: "Request timed out.",
    -1002: "Unsupported URL.",
    -1003: "Cannot find host.",
    -1004: "Cannot connect to host.",
    -1005: "Network connection lost.",
    -1007: "Too many redirects.",
    -1008: "Resource unavailable.",
    -1009: "You are not connected to the internet.",
    -1010: "Redirected to a page that does not exist.",
    -1011: "Bad server response.",
    -1012: "User authentication cancelled.",
    -1013: "User authentication required.",
    -1014: "Server indicated data was forthcoming, but terminated connection before sending any.",
    -1015: "Cannot decode raw data (encoding known, but data is invalid).",
    -1016: "Cannot decode content data (unknown encoding).",
    -1017: "Cannot parse response.",
    -1018: "Roaming is disabled.",
    -1019: "Phone call in progress and cell service does not support simultaneous phone and data communication.",
    -1020: "Data not allowed (cell network disallowed the connection).",
    -1021: "Body stream required, but client did not provide one.",
    -1022: "Secure connection required, but request was insecure (App Transport Security).",
    -1103: "Data length exceeds max.",
    -1200: "Could not establish a secure connection (-1200).",
    -1201: "Server certificate has an invalid date.",
    -1202: "Server certificate was signed by a root server that isn't trusted by iOS.",
    -1203: "Server certificate has an unknown root server.",
    -1204: "Server certificate not valid yet.",
    -1205: "Client certificate rejected.",
    -1206: "Client certificate required, but not provided."
]

public func urlLoadingErrorMessages() -> [ErrorMessage] {
    var errorMessages = [ErrorMessage]()
    for (code, message) in urlLoadingErrorCodesDict {
        errorMessages.append(SimpleErrorMessage(title: "Error", message: message, forCode: code))
    }
    return errorMessages
}

public class VerboseURLLoadingErrorHandler: NetworkErrorHandler {
    var errorMessages: [ErrorMessage] = urlLoadingErrorMessages()
    var errorMessageMap: [Int: ErrorMessage] {
        get {
            var map = [Int: ErrorMessage]()
            for message in errorMessages {
                map[message.forCode] = message
            }
            return map
        }
    }
    
    public init() {}
    
    open func alert(for error: NSError) -> UIViewController {
        print(error)
        if let message = errorMessageMap[error.code] {
            return FunNet.alert(message.title, message.message)
        } else {
            return FunNet.alert("Error \(error.code)", "Description: \(error.debugDescription)\nInfo: \(error.userInfo)")
        }
    }
}
