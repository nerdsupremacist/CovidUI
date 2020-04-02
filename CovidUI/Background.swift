
import Foundation
import SwiftUI
import Neumorphic

struct Background: View {
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    var body: some View {
        let neumorphic = Neumorphic(colorScheme: colorScheme)
        return neumorphic.mainColor()
    }
}
