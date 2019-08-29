//
//  VariadicParametersStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableVariadicProtocol {
  func variadicMethod(objects: @escaping @autoclosure () -> [String],
                      param2: @escaping @autoclosure () -> Int)
    -> Stubbable<VariadicProtocol, VariadicProtocolMock, ([String], Int) -> Void, Void>
  func variadicMethod(objects: @escaping @autoclosure () -> [Bool],
                      param2: @escaping @autoclosure () -> Int)
    -> Stubbable<VariadicProtocol, VariadicProtocolMock, ([Bool], Int) -> Void, Void>
  func variadicMethodAsFinalParam(param1: @escaping @autoclosure () -> Int,
                                  objects: @escaping @autoclosure () -> [String])
    -> Stubbable<VariadicProtocol, VariadicProtocolMock, (Int, [String]) -> Void, Void>
  func variadicReturningMethod(objects: @escaping @autoclosure () -> [Bool],
                               param2: @escaping @autoclosure () -> Int)
    -> Stubbable<VariadicProtocol, VariadicProtocolMock, ([Bool], Int) -> Bool, Bool>
}
extension VariadicProtocolMock: StubbableVariadicProtocol {}

private protocol StubbableVariadicClass {
  func variadicMethod(objects: @escaping @autoclosure () -> [String],
                      param2: @escaping @autoclosure () -> Int)
    -> Stubbable<VariadicClass, VariadicClassMock, ([String], Int) -> Void, Void>
  func variadicMethod(objects: @escaping @autoclosure () -> [Bool],
                      param2: @escaping @autoclosure () -> Int)
    -> Stubbable<VariadicClass, VariadicClassMock, ([Bool], Int) -> Void, Void>
  func variadicMethodAsFinalParam(param1: @escaping @autoclosure () -> Int,
                                  objects: @escaping @autoclosure () -> [String])
    -> Stubbable<VariadicClass, VariadicClassMock, (Int, [String]) -> Void, Void>
  func variadicReturningMethod(objects: @escaping @autoclosure () -> [Bool],
                               param2: @escaping @autoclosure () -> Int)
    -> Stubbable<VariadicClass, VariadicClassMock, ([Bool], Int) -> Bool, Bool>
}
extension VariadicClassMock: StubbableVariadicClass {}
