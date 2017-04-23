import Alamofire

@objc
public enum PactHTTPMethod: Int {
  case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

@objc
public class Interaction: NSObject {
  typealias HttpMessage = [String: Any]
  var providerState: String? = nil
  var testDescription: String = ""
  var request: HttpMessage = [:]
  var response: HttpMessage = [:]

  @discardableResult
  public func given(_ providerState: String) -> Interaction {
    self.providerState = providerState
    return self
  }

  @discardableResult
  public func uponReceiving(_ testDescription: String) -> Interaction {
    self.testDescription = testDescription
    return self
  }

  @objc(withRequestHTTPMethod: path: query: headers: body:)
  @discardableResult
  public func withRequest(_ method: PactHTTPMethod,
                        path: Any,
                        query: [String: Any]? = nil,
                        headers: [String: String]? = nil,
                        body: Any? = nil) -> Interaction {
    request = ["method": httpMethod(method)]
    request = applyPath(message: request, path: path)
    request = applyValue(message: request, field: "headers", value: headers)
    request = applyValue(message: request, field: "query", value: query)
    request = applyBody(message: request, body: body)
    return self
  }

  @objc(willRespondWithHTTPStatus: headers: body:)
  @discardableResult
  public func willRespondWith(_ status: Int,
                            headers: [String: String]? = nil,
                            body: Any? = nil) -> Interaction {
    response = ["status": status]
    response = applyValue(message: response, field: "headers", value: headers)
    response = applyBody(message: response, body: body)
    return self
  }

  private func applyValue(message: HttpMessage, field: String, value: Any?) -> HttpMessage {
    if let value = value {
      return message.merge(dictionary: [field: value]);
    }
    return message
  }

  private func applyPath(message: HttpMessage, path: Any) -> HttpMessage {
    switch path {
    case let matcher as MatchingRule:
      return message.merge(dictionary: [
        "path": matcher.value(),
        "matchingRules": ["$.path": matcher.rule()]])
    default:
      return message.merge(dictionary:["path": path])
    }
  }

  private func applyBody(message: HttpMessage, body: Any?) -> HttpMessage {
    if let bodyValue = body {
      let pactBody = PactBodyBuilder.init(body: bodyValue).build()
      return message.merge(dictionary: ["body" : pactBody.body,
                             "matchingRules" : matchingRules(message: message, matchingRules: pactBody.matchingRules)]);
    }
    return message
  }

  private func matchingRules(message: HttpMessage, matchingRules: PathWithMatchingRule) -> HttpMessage {
    switch message["matchingRules"] {
      case let existingMatchingRules as PathWithMatchingRule:
        return existingMatchingRules.merge(dictionary: matchingRules)
      default:
        return matchingRules
    }
  }

  public func payload() -> [String: Any] {
    var payload: [String: Any] = ["description": testDescription, "request": request, "response": response ]
    if let providerState = providerState {
      payload["providerState"] = providerState
    }
    return payload
  }

  private func httpMethod(_ method: PactHTTPMethod) -> String {
    switch method {
      case .GET:
        return "get"
      case .HEAD:
        return "head"
      case .POST:
        return "post"
      case .PUT:
        return "put"
      case .PATCH:
        return "patch"
      case .DELETE:
        return "delete"
      case .TRACE:
        return "trace"
      case .CONNECT:
        return "connect"
      default:
        return "get"
    }
  }
}
