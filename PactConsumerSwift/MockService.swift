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
  open func objcRun(_ testFunction: @escaping (_ testComplete: () -> Void) -> Void) {
    self.run(nil, line: nil, timeout: 30, testFunction: testFunction)
  }

  @objc(run: withTimeout:)
  open func objcRun(_ testFunction: @escaping (_ testComplete: () -> Void) -> Void,
                    timeout: TimeInterval) {
    self.run(nil, line: nil, timeout: timeout, testFunction: testFunction)
  }

  open func run(_ file: String? = #file, line: UInt? = #line,
                timeout: TimeInterval = 30,
                testFunction: @escaping (_ testComplete: @escaping () -> Void) -> Void) {
    waitUntilWithLocation(timeout: timeout, file: file, line: line) { done in
      self.pact.withInteractions(self.interactions)
      self.mockServer.withPact(self.pact)
      testFunction { () in
        done()
      }
    }
    if !self.mockServer.matched() {
      self.failWithLocation("Actual request did not match expectations." +
        " Mismatches: \(String(describing: self.mockServer.mismatches()))",
        file: file,
        line: line)
      print("warning: Make sure the testComplete() fuction is called at the end of your test.")
    } else {
      self.mockServer.writeFile()
    }
    self.mockServer.cleanup()
  }

  func failWithLocation(_ message: String, file: String?, line: UInt?) {
    if let fileName = file, let lineNumber = line {
      fail(message, file: fileName, line: lineNumber)
    } else {
      fail(message)
    }
  }

  public func waitUntilWithLocation(timeout: TimeInterval,
                                    file: FileString?,
                                    line: UInt?,
                                    action: @escaping (@escaping () -> Void) -> Void) {
    if let fileName = file, let lineNumber = line {
      return waitUntil(timeout: timeout, file: fileName, line: lineNumber, action: action)
    } else {
      return waitUntil(timeout: timeout, action: action)
    }
  }

}
