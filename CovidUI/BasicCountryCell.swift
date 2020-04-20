
import Foundation
import SwiftUI

struct BasicCountryCell: View {
    let api: Covid
    
    @GraphQL(Covid.Country.name)
    var name: String

    @GraphQL(Covid.Country.identifier)
    var identifier: Covid.CountryIdentifier

    @GraphQL(Covid.Country.info.iso2)
    var countryCode: String?

    @GraphQL(Covid.Country.cases)
    var cases: Int

    var body: some View {
        NavigationLink(destination: api.countryDetailView(identifier: identifier)) {
            HStack {
                countryCode.flatMap(emoji(countryCode:)).map { Text($0).bold().foregroundColor(.primary) }
                Text(name).bold().foregroundColor(.primary)
                Spacer()
                Text("\(cases) Cases").foregroundColor(.secondary)
            }
        }
    }
}
