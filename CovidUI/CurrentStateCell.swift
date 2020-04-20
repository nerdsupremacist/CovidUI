
import Foundation
import SwiftUI
import Neumorphic

struct CurrentStateCell: View {
    @GraphQL(Covid.World.affected)
    var affected: StatsView.Affected

    var body: some View {
        NeumporphicCard {
            StatsView(affected: affected).padding(.horizontal, 32)
        }
    }

}
