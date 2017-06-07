import Quick
import Nimble
import PactConsumerSwift
import SwiftyJSON

class PactQueryBuilderSpec: QuickSpec {
  override func spec() {

    context("dictionary based query") {
      context("no matching rules") {
        let pactQuery = PactQueryBuilder(query: [
          "name": "Mary",
          "type": "alligator"]
          ).build()

        it("builds matching rules") {
          let matchingRules = JSON(pactQuery.matchingRules)

          expect(matchingRules).to(equal([:]))
        }

        it("builds json body") {
          let query = JSON(pactQuery.query)

          expect(query).to(equal("name=Mary&type=alligator"))
        }
      }

      context("matching rules") {
        let pactQuery = PactQueryBuilder(query: [
          "name": Matcher.somethingLike("Mary"),
          "type": Matcher.somethingLike("alligator")]
          ).build()

        it("builds matching rules") {
          let matchingRules = JSON(pactQuery.matchingRules)

          expect(matchingRules).to(equal(["$.query.name[0]": ["match": "type"], "$.query.type[0]": ["match": "type"]]))
        }

        it("builds json body") {
          let query = JSON(pactQuery.query)

          expect(query).to(equal("name=Mary&type=alligator"))
        }
      }
    }

    context("string based query") {
      let pactQuery = PactQueryBuilder(query: "live=water").build()

      it("builds matching rules") {
        let matchingRules = JSON(pactQuery.matchingRules)

        expect(matchingRules).to(equal([:]))
      }

      it("builds json body") {
        let query = JSON(pactQuery.query)

        expect(query).to(equal("live=water"))
      }
    }
  }
}
