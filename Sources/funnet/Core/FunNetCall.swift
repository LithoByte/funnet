//
//  FunkyNetworkCall.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/20/19.
//

import Foundation
import Prelude

public class FunNetCall: NetworkCall, Fireable {
    public typealias ResponderType = NetworkResponder
    
    public var configuration: ServerConfiguration
    public var endpoint: Endpoint
    public var responder: NetworkResponder? = nil
    
    public var firingFunc: (FunNetCall) -> Void = fire(_:)
    
    public init(configuration: ServerConfiguration, _ endpoint: Endpoint, responder: NetworkResponder? = nil){
        self.configuration = configuration
        self.endpoint = endpoint
        self.responder = responder
    }
    
    public func fire() {
        firingFunc(self)
    }
}
