import Quick
import Nimble
import PactConsumerSwift
import SwiftyJSON

class PactBodyBuilderSpec: QuickSpec {
  override func spec() {

    context("no matching rules") {
      let pactBody = PactBodyBuilder( body: [
        "name": "Mary",
        "type": "alligator",
        "friends": [ "Bob", "Jane" ]]
        ).build()

      it("builds matching rules") {
        let matchingRules = JSON(pactBody.matchingRules)

        expect(matchingRules).to(equal([:]))
      }

      it("builds json body") {
        let body = JSON(pactBody.body)

        expect(body).to(equal(["name": "Mary",
                               "type": "alligator",
                               "friends": [ "Bob", "Jane" ]]))
      }
    }

    context("constructs matcher in dictionary") {
      let pactBody = PactBodyBuilder( body: [
                                           "name": "Mary",
                                           "type": "alligator",
                                           "legs": Matcher.somethingLike(4)]
        ).build()

      it("builds matching rules") {
        let matchingRules = JSON(pactBody.matchingRules)

        expect(matchingRules).to(equal(["$.body.legs": ["match": "type"]]))
      }

      it("builds json body") {
        let body = JSON(pactBody.body)

        expect(body).to(equal(["name": "Mary",
                               "type": "alligator",
                               "legs": 4]))
      }
    }

    context("constructs matcher in array") {
      let pactBody = PactBodyBuilder( body: [ "friends": [ Matcher.somethingLike("Bob") ] ]
        ).build()

      it("builds matching rules") {
        let matchingRules = JSON(pactBody.matchingRules)

        expect(matchingRules).to(equal(["$.body.friends[0]": ["match": "type"]]))
      }

      it("builds json body") {
        let body = JSON(pactBody.body)

        expect(body).to(equal(["friends": [ "Bob" ] ]))
      }
    }

    context("with multiple matches") {
      let pactBody = PactBodyBuilder( body: [
        "name": "Mary",
        "skills": [ [ "type": Matcher.somethingLike("building"), "time": Matcher.somethingLike("3 years") ] ],
        "relations": [ "friends": [ "Jane", Matcher.somethingLike("Bob") ] ]]
        ).build()

      it("builds matching rules") {
        let matchingRules = JSON(pactBody.matchingRules)

        expect(matchingRules).to(equal([
          "$.body.relations.friends[1]": ["match": "type"] ,
          "$.body.skills[0].type": ["match": "type"] ,
          "$.body.skills[0].time": ["match": "type"]
        ]))
      }

      it("builds json body") {
        let body = JSON(pactBody.body)

        expect(body).to(equal([
          "name": "Mary",
          "skills": [ [ "type": "building", "time": "3 years" ] ],
          "relations": [ "friends": [ "Jane", "Bob" ] ] ]
        ))
      }
    }
  }
}
