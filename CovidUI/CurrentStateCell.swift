
import Foundation
import SwiftUI
import Neumorphic

struct CurrentStateCell: View {
    @GraphQL(Covid.World.iAffected)
    var affected: StatsView.IAffected

    var body: some View {
        NeumporphicCard {
            StatsView(iAffected: affected).padding(.horizontal, 32)
        }
    }

}
