
import Foundation
import SwiftUI

struct BasicCountryCell: View {
    let api: Covid
    
    @GraphQL(Covid.Country.name)
    var name: String

    @GraphQL(Covid.Country.identifier)
    var identifier

    @GraphQL(Covid.Country.info.emoji)
    var emoji

    @GraphQL(Covid.Country.cases)
    var cases

    var body: some View {
        NavigationLink(destination: api.countryDetailView(identifier: identifier)) {
            HStack {
                emoji.map { Text($0).bold().foregroundColor(.primary) }
                Text(name).bold().foregroundColor(.primary)
                Spacer()
                Text(L10n.Cases.number(cases)).foregroundColor(.secondary)
            }
        }
    }
}
