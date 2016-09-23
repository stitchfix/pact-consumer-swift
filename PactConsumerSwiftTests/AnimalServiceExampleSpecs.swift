import Quick
import Nimble
import PactConsumerSwift

class PactTest {

  func defines() {

  }
}

class AnimalServiceExampleSpec: PactTest {

  var animalServiceClient: AnimalServiceClient?

  override func defines() {
    //    hasPactBetween(provider: 'Animal Service', consumer: 'Animal Consumer iOS') {
    //
    //      beforeEach { baseUrl in
    //        animalServiceClient = AnimalServiceClient(baseUrl: baseUrl)
    //      }
    //
    //      given("an alligator exists")
    //        .uponReceiving("a request for an alligator")
    //        .withRequest(method:.GET, path: "/alligator")
    //        .willRespondWith(status: 200,
    //                         headers: ["Content-Type": "application/json"],
    //                         body: ["name": "Mary", "type": "alligator"])
    //
    //
    //      when('a request for an alligator') { (testcomplete) -> Void in
    //        animalServiceClient!.getAlligator( { (alligator) in
    //          expect(alligator.name).to(equal("Mary"))
    //          testComplete()
    //        }, failure: { (error) in
    //            testComplete()
    //        })
    //      }
    //    }
  }
}

