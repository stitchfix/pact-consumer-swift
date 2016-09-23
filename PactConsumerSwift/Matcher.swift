import Foundation

@objc
open class Matcher: NSObject {

  @objc
  open class func term(_ matcher: String, generate: String) -> [String: Any] {
    return [ "json_class": "Pact::Term",
      "data": [
        "generate": generate,
        "matcher": [
          "json_class": "Regexp",
          "o": 0,
          "s": matcher]
      ] ]
  }

  @objc
  open class func somethingLike(_ value: Any) -> TypeMatcher {
    return TypeMatcher(value: value)
  }

  @objc
  open class func eachLike(_ value: Any, min: Int = 1) -> [String: Any] {
    return [
      "json_class": "Pact::ArrayLike",
      "contents": value,
      "min": min
    ]
  }
}

@objc
public class TypeMatcher: NSObject, MatchingRule {
  let typeValue: Any

  public init(value: Any) {
    self.typeValue = value
  }

  internal func rule() -> [String : String] {
    return [ "match": "type" ]
  }

  internal func value() -> Any {
    return typeValue
  }
}

protocol MatchingRule {
  func value() -> Any
  func rule() -> [String: String]
}
