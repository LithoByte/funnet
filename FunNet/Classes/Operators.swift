//
//  Operators.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/24/19.
//

import Prelude

infix operator >?>: Composition
public func >?><A, B, C>(f: @escaping (A) -> B?, g: @escaping (B) -> C) -> (A) -> C? {
    return { a in
        if let b = f(a) {
            return g(b)
        } else {
            return nil
        }
    }
}

infix operator <>: Composition
public func <><A>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
    return { a in
        f(a)
        g(a)
    }
}

infix operator <~>: Composition
public func <~><A>(f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void) -> (inout A) -> Void {
    return { a in
        f(&a)
        g(&a)
    }
}

infix operator />: ForwardApplication
public func /><A>(a: inout A, f: @escaping (inout A) -> Void) -> Void {
    f(&a)
}

infix operator >|>: Composition
public func >|><A, B, C>(a: A, f: @escaping (A, B) -> C) -> (B) -> C {
    return { b in f(a, b) }
}

infix operator >||>: Composition
public func >||><A, B, C>(b: B, f: @escaping (A, B) -> C) -> (A) -> C {
    return { a in f(a, b) }
}
