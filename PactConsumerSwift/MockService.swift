import Foundation
import Nimble

@objc
open class MockService: NSObject {
  fileprivate let pact: Pact
  fileprivate let mockServer: NativeMockServer
  fileprivate var interactions: [Interaction] = []

  open var baseUrl: String {
    return "http://localhost:\(mockServer.port)"
  }

  public init(provider: String, consumer: String, mockServer: NativeMockServer) {
    self.pact = Pact(provider: provider, consumer: consumer)
    self.mockServer = mockServer
  }

  @objc(initWithProvider: consumer: )
  public convenience init(provider: String, consumer: String) {
    self.init(provider: provider, consumer: consumer, mockServer: NativeMockServer())
  }

  open func given(_ providerState: String) -> Interaction {
    let interaction = Interaction().given(providerState)
    interactions.append(interaction)
    return interaction
  }

  @objc(uponReceiving:)
  open func uponReceiving(_ description: String) -> Interaction {
    let interaction = Interaction().uponReceiving(description)
    interactions.append(interaction)
    return interaction
  }

  @objc(run:)
  open func objcRun(_ testFunction: @escaping (_ testComplete: () -> Void) -> Void) -> Void {
    self.run(nil, line: nil, timeout: 30, testFunction: testFunction)
  }

  @objc(run: withTimeout:)
  open func objcRun(_ testFunction: @escaping (_ testComplete: () -> Void) -> Void, timeout: TimeInterval) -> Void {
    self.run(nil, line: nil, timeout: timeout, testFunction: testFunction)
  }

  open func run(_ file: String? = #file, line: UInt? = #line,
                timeout: TimeInterval = 30,
                testFunction: @escaping (_
                  testComplete: @escaping () -> Void) -> Void) -> Void {
    var complete = false
    pact.withInteractions(interactions)
    mockServer.withPact(pact)
    testFunction { () in
      complete = true
      if !self.mockServer.matched() {
        print("Actual request did not match expectations. Mismatches: ")
        print(self.mockServer.mismatches() ?? "error returning matches")
        self.failWithLocation("Actual request did not match expectations. Mismatches: \(self.mockServer.mismatches())", file: file, line: line)
      }
      self.mockServer.writeFile()
      self.mockServer.cleanup()
    }
    if let fileName = file, let lineNumber = line {
      expect(fileName, line: lineNumber, expression: { complete }).toEventually(beTrue(),
        timeout: timeout,
        description: "Expected requests were never received. " +
          "Make sure the testComplete() fuction is called at the end of your test.")
    } else {
      expect(complete).toEventually(beTrue(),
        timeout: timeout,
        description: "Expected requests were never received. " +
          "Make sure the testComplete() fuction is called at the end of your test.")
    }
  }


  func failWithLocation(_ message: String, file: String?, line: UInt?) {
    if let fileName = file, let lineNumber = line {
      fail(message, file: fileName, line: lineNumber)
    } else {
      fail(message)
    }
  }
}
