//
//  FunkyNetworkCall.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/20/19.
//

import Foundation
import Prelude

public class FunNetCall: NetworkCall, Stubbable, Fireable {
    public typealias ResponderType = NetworkResponder
    
    public var configuration: ServerConfigurationProtocol
    public var endpoint: EndpointProtocol
    public var responder: NetworkResponder? = nil
    public var stubHolder: StubHolderProtocol? = nil
    public lazy var stubCondition: (URLRequest) -> Bool
        = defaultStubCondition(configuration: self.configuration, endpoint: self.endpoint)
    
    public var firingFunc: (FunNetCall) -> Void = fire(_:)
    
    public init(configuration: ServerConfigurationProtocol, _ endpoint: EndpointProtocol, responder: NetworkResponder? = nil){
        self.configuration = configuration
        self.endpoint = endpoint
        self.responder = responder
    }
    
    public func fire() {
        firingFunc(self)
    }
}

public func fireCall(_ call: Fireable) {
    call.fire()
}
