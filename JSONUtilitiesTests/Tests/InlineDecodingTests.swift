//
//  InlineDecodingTests.swift
//  JSONUtilities
//
//  Created by Luciano Marisi on 15/05/2016.
//  Copyright © 2016 TechBrewers LTD. All rights reserved.
//

import XCTest
@testable import JSONUtilities

private let randomKey = "aaaaaaa"

class InlineDecodingTests: XCTestCase {

  func testDecodingOfJSONRawTypes() {
    let expectedInt: Int = 1
    expectDecodeType(expectedInt)
    
    let expectedFloat: Float = 2.2
    expectDecodeType(expectedFloat)

    let expectedDouble: Double = 2.2
    expectDecodeType(expectedDouble)

    let expectedString: String = "something"
    expectDecodeType(expectedString)

    let expectedBool: Bool = true
    expectDecodeType(expectedBool)
  }
  
  func testDecodingOfJSONDictionary() {
    
    let expectedValue: JSONDictionary = ["key1": "value1", "key2": "value2"]
    let dictionary = ["key": expectedValue]
    let decodedValue: JSONDictionary = try! dictionary.jsonKey("key")
    XCTAssert(decodedValue == expectedValue)
    
    let decodedOptionalInt: JSONDictionary? = dictionary.jsonKey("key")
    XCTAssert(decodedOptionalInt == expectedValue)
    
    do {
      let _: JSONDictionary = try dictionary.jsonKey(randomKey)
    } catch let error {
      let expectedError = DecodingError.MandatoryKeyNotFound(key: randomKey)
      let actualError = error as! DecodingError
      XCTAssert(actualError == expectedError)
    }
    
    let decodedMissingInt: JSONDictionary? = dictionary.jsonKey(randomKey)
    XCTAssertNil(decodedMissingInt)
  }
  
  
  func testDecodingOfJSONRawTypesArray() {
    let expectedInt: [Int] = [1]
    expectDecodeTypeArray(expectedInt)
    
    let expectedFloat: [Float] = [2.2]
    expectDecodeTypeArray(expectedFloat)
    
    let expectedDouble: [Double] = [2.2]
    expectDecodeTypeArray(expectedDouble)
    
    let expectedString: [String] = ["something"]
    expectDecodeTypeArray(expectedString)
    
    let expectedBool: [Bool] = [true]
    expectDecodeTypeArray(expectedBool)
  }
  
  func testIncorrectEnum() {
    
    let dictionary = ["enum": "three"]
    
    do {
      let _:MockParent.MockEnum = try dictionary.jsonKey("enumIncorrect")
      XCTAssertThrowsError("Did not catch MandatoryKeyNotFound error")
    }
    catch let error {
      let expectedError = DecodingError.MandatoryKeyNotFound(key: "enumIncorrect")
      let actualError = error as! DecodingError
      XCTAssert(expectedError == actualError)
    }
    
    do {
      let _:MockParent.MockEnum = try dictionary.jsonKey("enum")
      XCTAssertThrowsError("Did not catch MandatoryRawRepresentableHasIncorrectValue error")
    }
    catch let error {
      let expectedError = DecodingError.MandatoryRawRepresentableHasIncorrectValue(rawRepresentable: MockParent.MockEnum.self, rawValue: "three")
      let actualError = error as! DecodingError
      XCTAssert(expectedError == actualError)
    }
  }
  
  func test_decodingMandatoryEnumArray_withKey() {
    let dictionary: JSONDictionary = ["enums": ["one", "!@1", "two"]]
    
    let decodedEnums: [MockParent.MockEnum] = try! dictionary.jsonKey("enums")
    
    let expectedEnums: [MockParent.MockEnum] = [.one, .two]
    XCTAssertEqual(decodedEnums, expectedEnums)
  }

  
  func test_decodingOptionalEnumArray_withKey() {
    let dictionary: JSONDictionary = ["enums": ["one", "!@1", "two"]]
    
    let decodedEnums: [MockParent.MockEnum]? = dictionary.jsonKey("enums")
    
    let expectedEnums: [MockParent.MockEnum] = [.one, .two]
    XCTAssertEqual(decodedEnums!, expectedEnums)
  }
  
  func test_decodingMandatoryEnumArray_withoutKey() {
    let dictionary: JSONDictionary = ["enums": ["one", "!@1", "two"]]
    
    do {
      let _: [MockParent.MockEnum] = try dictionary.jsonKey("invalid_key")
      XCTFail("Error not thrown")
    } catch {
      let expectedError = DecodingError.MandatoryKeyNotFound(key: "invalid_key")
      XCTAssert(error as! DecodingError == expectedError)
    }

  }
  
  func test_decodingOptionalEnumArray_withoutKey() {
    let dictionary: JSONDictionary = ["enums": ["one", "!@1", "two"]]
    
    let decodedEnums: [MockParent.MockEnum]? = dictionary.jsonKey("invalid_key")
    
    XCTAssertNil(decodedEnums)
  }
  
  func testDecodingOfJSONDictionaryArray() {
    
    let expectedValue: [JSONDictionary] = [["key1": "value1"], ["key2": "value2"]]
    let dictionary = ["key": expectedValue]
    let decodedValue: [JSONDictionary] = try! dictionary.jsonKey("key")
    XCTAssert(decodedValue == expectedValue)
    
    let decodedOptionalInt: [JSONDictionary]? = dictionary.jsonKey("key")
    XCTAssert(decodedOptionalInt == expectedValue)
    
    do {
      let _: [JSONDictionary] = try dictionary.jsonKey(randomKey)
    } catch let error {
      let expectedError = DecodingError.MandatoryKeyNotFound(key: randomKey)
      let actualError = error as! DecodingError
      XCTAssert(actualError == expectedError)
    }
    
    let decodedMissingInt: [JSONDictionary]? = dictionary.jsonKey(randomKey)
    XCTAssertNil(decodedMissingInt)
  }
  
  func testSomeInvalidDecodableTypes() {
    let parentDictionary = ["children" : ["john", ["name": "jane"]]]
    let decodedParent: MockSimpleParent = try! MockSimpleParent(jsonDictionary: parentDictionary)
    XCTAssert(decodedParent.children.count == 1)
  }
  
  // MARK: Helpers
  
  private func expectDecodeType<ExpectedType: protocol<JSONRawType, Equatable>>(expectedValue: ExpectedType, file: StaticString = #file, line: UInt = #line) {
    
    let dictionary = ["key": expectedValue]
    let decodedValue: ExpectedType = try! dictionary.jsonKey("key")
    XCTAssertEqual(decodedValue, expectedValue, file: file, line: line)
    
    let decodedOptionalInt: ExpectedType? = dictionary.jsonKey("key")
    XCTAssertEqual(decodedOptionalInt!, expectedValue, file: file, line: line)
    
    do {
      let _: ExpectedType = try dictionary.jsonKey(randomKey)
    } catch let error {
      let expectedError = DecodingError.MandatoryKeyNotFound(key: randomKey)
      let actualError = error as! DecodingError
      XCTAssert(actualError == expectedError, file: file, line: line)
    }
    
    let decodedMissingInt: ExpectedType? = dictionary.jsonKey(randomKey)
    XCTAssertNil(decodedMissingInt)
  }

  private func expectDecodeTypeArray<ExpectedType: protocol<JSONRawType, Equatable>>(expectedValue: [ExpectedType], file: StaticString = #file, line: UInt = #line) {
    
    let dictionary = ["key": expectedValue]
    let decodedValue: [ExpectedType] = try! dictionary.jsonKey("key")
    XCTAssertEqual(decodedValue, expectedValue, file: file, line: line)
    
    let decodedOptionalInt: [ExpectedType]? = dictionary.jsonKey("key")
    XCTAssertEqual(decodedOptionalInt!, expectedValue, file: file, line: line)
    
    do {
      let _: [ExpectedType] = try dictionary.jsonKey(randomKey)
    } catch let error {
      let expectedError = DecodingError.MandatoryKeyNotFound(key: randomKey)
      let actualError = error as! DecodingError
      XCTAssert(actualError == expectedError, file: file, line: line)
    }
    
    let decodedMissingInt: [ExpectedType]? = dictionary.jsonKey(randomKey)
    XCTAssertNil(decodedMissingInt)
  }
  
}

func ==(lhs: DecodingError, rhs: DecodingError) -> Bool {
  return lhs.description == rhs.description
}
