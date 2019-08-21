//
//  MockableType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct MockableType: Hashable, Comparable {
  let name: String
  let moduleName: String
  let kind: SwiftDeclarationKind
  let methods: Set<Method>
  let methodsCount: [Method.Reduced: UInt] // For de-duping generic methods.
  let variables: Set<Variable>
  let inheritedTypes: Set<MockableType>
  let genericTypes: [GenericType]
  let genericConstraints: [String]
  private(set) var shouldMock: Bool
  let attributes: Attributes
  
  static func < (lhs: MockableType, rhs: MockableType) -> Bool {
    return lhs.name < rhs.name
  }
  
  init?(from rawType: RawType, mockableTypes: [String: MockableType]) {
    guard let substructure = rawType.dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary],
      let rawKind = rawType.dictionary[SwiftDocKey.kind.rawValue] as? String,
      let kind = SwiftDeclarationKind(rawValue: rawKind) else { return nil }
    guard let rawAccessLevel = rawType.dictionary[AccessLevel.accessLevelKey] as? String,
      let accessLevel = AccessLevel(rawValue: rawAccessLevel),
      accessLevel != .fileprivate, accessLevel != .private else { return nil }
    
    self.attributes = Attributes.create(from: rawType.dictionary)
    guard !attributes.contains(.final) else { return nil }
    
    self.name = rawType.name
    self.moduleName = rawType.parsedFile.moduleName
    self.kind = kind
    var methods = Set<Method>()
    var variables = Set<Variable>()
    var inheritedTypes = Set<MockableType>()
    for structure in substructure {
      if let method = Method(from: structure, rootKind: kind, rawType: rawType) {
        methods.insert(method)
      }
      if let variable = Variable(from: structure, rootKind: kind, rawType: rawType) {
        variables.insert(variable)
      }
    }
    if let rawInheritedTypes = rawType.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] {
      for type in rawInheritedTypes {
        guard let typeName = type[SwiftDocKey.name.rawValue] as? String,
          let mockableType = mockableTypes[typeName] else { continue }
        methods = methods.union(mockableType.methods)
        variables = variables.union(mockableType.variables)
        inheritedTypes = inheritedTypes.union([mockableType] + mockableType.inheritedTypes)
      }
    }
    self.methods = methods
    self.variables = variables
    self.inheritedTypes = inheritedTypes
    self.shouldMock = rawType.parsedFile.shouldMock
    
    var methodsCount = [Method.Reduced: UInt]()
    methods.forEach({ methodsCount[Method.Reduced(from: $0), default: 0] += 1 })
    self.methodsCount = methodsCount
    
    self.genericTypes = substructure.compactMap({ structure -> GenericType? in
      guard let genericType = GenericType(from: structure, rawType: rawType) else { return nil }
      return genericType
    })
    
    var genericConstraints = [String]()
    if kind == .class {
      let source = rawType.parsedFile.file.contents
      if let nameSuffix = SourceSubstring.nameSuffixUpToBody.extract(from: rawType.dictionary, contents: source) {
        if let whereRange = nameSuffix.range(of: #"\bwhere\b"#, options: .regularExpression) {
          genericConstraints = nameSuffix[whereRange.upperBound..<nameSuffix.endIndex]
            .substringComponents(separatedBy: ",")
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
        }
      }
    }
    self.genericConstraints = genericConstraints
  }
  
  static func clone(_ other: MockableType, shouldMock: Bool) -> MockableType {
    var clone = other
    clone.shouldMock = shouldMock
    return clone
  }
}
