
import Foundation
import SwiftUI
import Neumorphic

struct CurrentStateCell: View {
    @GraphQL(Covid.World.cases)
    var cases: Int

    @GraphQL(Covid.World.deaths)
    var deaths: Int

    @GraphQL(Covid.World.recovered)
    var recovered: Int

    var body: some View {
        NeumporphicCard {
            HStack {
                VStack {
                    Text("Cases").font(.headline).fontWeight(.bold).foregroundColor(.primary)
                    Text(cases.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
                }

                Spacer()
                Divider().padding(.vertical, 8)
                Spacer()

                VStack {
                    Text("Deaths").font(.headline).fontWeight(.bold).foregroundColor(.primary)
                    Text(deaths.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
                }

                Spacer()
                Divider().padding(.vertical, 8).foregroundColor(.primary)
                Spacer()

                VStack {
                    Text("Recovered").font(.headline).fontWeight(.bold).foregroundColor(.primary)
                    Text(recovered.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
    }

}
