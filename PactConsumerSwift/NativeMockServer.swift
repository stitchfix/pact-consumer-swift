import Foundation
import PactMockServer
import Nimble

open class NativeMockServer {
  open var port: Int32 = -1
  open var pactDir: String

  public init(_ directory: String = "./pacts") {
    pactDir = directory
    port = randomPort()
  }

  func randomPort() -> Int32 {
    return Int32(arc4random_uniform(200) + 4000)
  }

  open func withPact(_ pact: Pact) {
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: pact.payload())
      let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8)

      // iOS json generation adds extra backslashes to "application/json" --> "application\\/json" 
      // causing the MockServer to fail to parse the file.
      let sanitizedString = jsonString!.replacingOccurrences(of: "\\/", with: "/")
      let result = PactMockServer.create_mock_server(sanitizedString, port)
      if result < 0 {
        switch result {
        case -1:
          fail("Mock server creation failed, pact supplied was nil")
        case -2:
          fail("Mock server creation failed, pact JSON file could not be parsed")
        default:
          fail("Mock server creation failed, result: \(result)")
        }
      }
      print("Server started on port \(port)")
    } catch let error as NSError {
      print(error)
    }
  }

  open func mismatches() -> String? {
    let mismatches = PactMockServer.mock_server_mismatches(port)
    if let mismatches = mismatches {
      return String(cString: mismatches)
    } else {
      return nil
    }
  }

  open func matched() -> Bool {
    return PactMockServer.mock_server_matched(port)
  }

  open func writeFile() {
    PactMockServer.write_pact_file(port, pactDir)
    print("notify: You can find the generated pact files here: \(self.pactDir)")
  }

  open func cleanup() {
    PactMockServer.cleanup_mock_server(port)
  }

}
