
import Foundation
import SwiftUI
import Neumorphic
import SwiftUICharts

struct FeaturedCountryCell: View {
    let api: Covid

    @GraphQL(Covid.Country.name)
    var name

    @GraphQL(Covid.Country.info.emoji)
    var emoji

    @GraphQL(Covid.Country.iAffected)
    var affected: StatsView.IAffected

    @GraphQL(Covid.Country.todayDeaths)
    var todayDeaths

    @GraphQL(Covid.Country.timeline.cases.graph._forEach(\.value))
    var casesOverTime

    var body: some View {
        NeumporphicCard {
            VStack(alignment: .leading) {
                HStack {
                    emoji.map { Text($0).font(.title).fontWeight(.bold).foregroundColor(.primary) }
                    Text(self.name).font(.title).fontWeight(.bold).foregroundColor(.primary)
                }

                Spacer()

                Text(L10n.Country.deaths(todayDeaths, name))
                    .font(.body)
                    .fontWeight(.light)
                    .lineLimit(0)
                    .foregroundColor(.secondary)

                Spacer()

                StatsView(iAffected: affected).padding(.horizontal, 16).padding(.top, 8)
                LineView(
                    data: casesOverTime.map(Double.init),
                    title: L10n.Headline.timeline,
                    style: ChartStyle.neumorphicColors(),
                    valueSpecifier: "%.0f"
                ).frame(height: 340)
            }.padding(.all, 16)
        }
    }

}

extension ChartStyle {

    static let darkStyle: ChartStyle = {
        let neumorphic = Neumorphic(colorScheme: .dark)
        return ChartStyle(backgroundColor: neumorphic.mainColor(),
                          accentColor: .primary,
                          gradientColor: GradientColors.prplPink,
                          textColor: .primary,
                          legendTextColor: .secondary,
                          dropShadowColor: neumorphic.darkShadowColor())
    }()

    static let lightStyle: ChartStyle = {
        let neumorphic = Neumorphic(colorScheme: .light)
        let style = ChartStyle(backgroundColor: neumorphic.mainColor(),
                               accentColor: .primary,
                               gradientColor: GradientColors.orange,
                               textColor: .primary,
                               legendTextColor: .secondary,
                               dropShadowColor: neumorphic.darkShadowColor())
        style.darkModeStyle = darkStyle
        return style
    }()

    static func neumorphicColors() -> ChartStyle {
        return lightStyle
    }

}
