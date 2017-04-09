import Quick
import Nimble
import PactConsumerSwift
import SwiftyJSON

class InteractionSpec: QuickSpec {
  override func spec() {
    var interaction: Interaction?
    beforeEach { interaction = Interaction() }

    describe("interaction state setup") {
      it("it initialises the provider state") {
        expect(interaction?.given("some state").providerState).to(equal("some state"))
      }
      
    }

    describe("json payload"){
      context("pact state") {
        it("includes provider state in the payload") {
          var payload = interaction!.given("state of awesomeness").uponReceiving("an important request is received").payload()

          expect(payload["providerState"] as! String?) == "state of awesomeness"
          expect(payload["description"] as! String?) == "an important request is received"
        }
      }

      context("no provider state") {
        it("doesn not include provider state when not included") {
          var payload = interaction!.uponReceiving("an important request is received").payload()

          expect(payload["providerState"]).to(beNil())
        }
      }

      context("request") {
        let method: PactHTTPMethod = .PUT
        let path = "/path"
        let headers = ["header": "value"]
        let body = "blah"

        it("returns expected request with specific headers and body") {
          var payload = interaction!.withRequest(method, path: path, headers: headers, body: body).payload()

          var request = payload["request"] as! [String: AnyObject]
          expect(request["path"] as! String?) == path
          expect(request["method"] as! String?).to(equal("put"))
          expect(request["headers"] as! [String: String]?).to(equal(headers))
          expect(request["body"] as! String?).to(equal(body))
        }

        it("returns expected request without body and headers") {
          var payload = interaction!.withRequest(method, path: path).payload()

          var request = payload["request"] as! [String: AnyObject]
          expect(request["path"] as! String?) == path
          expect(request["method"] as! String?).to(equal("put"))
          expect(request["headers"] as! [String: String]?).to(beNil())
          expect(request["body"] as! String?).to(beNil())
        }
      }

      context("response") {
        let statusCode = 200
        let headers = ["header": "value"]
        let body = "body"

        it("returns expected response with specific headers and body") {
          var payload = interaction!.willRespondWith(statusCode, headers: headers, body: body).payload()

          var response = payload["response"] as! [String: AnyObject]
          expect(response["status"] as! Int?) == statusCode
          expect(response["headers"] as! [String: String]?).to(equal(headers))
          expect(response["body"] as! String?).to(equal(body))
        }

        context("body with matcher") {
          let body  = [
            "type": "alligator",
            "legs": Matcher.somethingLike(4)] as [String : Any]
          var response : [String: Any]?

          beforeEach {
            interaction!.willRespondWith(statusCode, headers: headers, body: body)
            response = interaction!.payload()["response"] as? [String: Any]
          }

          it("builds matching rules") {
            let matchingRules = JSON(response!["matchingRules"]!)
            expect(matchingRules).to(equal(["$.body.legs": ["match": "type"]]))
          }

          it("adds default value to body") {
            let generatedBody = JSON(response!["body"]!)
            expect(generatedBody).to(equal(["type": "alligator", "legs": 4]))
          }
        }
      }
    }
  }
}
