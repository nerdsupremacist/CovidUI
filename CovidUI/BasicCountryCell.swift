
import Foundation
import SwiftUI

struct BasicCountryCell: View {
    @GraphQL(Covid.Country.name)
    var name: String

    @GraphQL(Covid.Country.info.iso2)
    var countryCode: String?

    @GraphQL(Covid.Country.cases)
    var cases: Int

    var body: some View {
        HStack {
            countryCode.flatMap(emoji(countryCode:)).map { Text($0).bold() }
            Text(name).bold()
            Spacer()
            Text("\(cases) Cases")
        }
    }
}
