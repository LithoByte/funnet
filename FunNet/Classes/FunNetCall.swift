//
//  FunkyNetworkCall.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/20/19.
//

import Foundation
import Prelude

public struct FunNetCall: Fireable, Stubbable {
    public var configuration: ServerConfigurationProtocol
    public var endpoint: EndpointProtocol
    public var responder: NetworkResponderProtocol? = nil
    public var stubHolder: StubHolderProtocol? = nil
    public lazy var stubCondition: (URLRequest) -> Bool
        = defaultStubCondition(configuration: self.configuration, endpoint: self.endpoint)
    
    public var firingFunc: (FunNetCall) -> Void = fireStubbable(_:)
    
    public init(configuration: ServerConfigurationProtocol, _ endpoint: EndpointProtocol, responder: NetworkResponderProtocol? = nil){
        self.configuration = configuration
        self.endpoint = endpoint
        self.responder = responder
    }
    
    public func fire() {
        firingFunc(self)
    }
}
