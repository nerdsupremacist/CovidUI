
import Foundation
import SwiftUI
import Neumorphic
import SwiftUICharts

struct FeaturedCountryCell: View {
    let api: Covid

    @GraphQL(Covid.Country.name)
    var name: String

    @GraphQL(Covid.Country.info.iso2)
    var countryCode: String?

    @GraphQL(Covid.Country.affected)
    var affected: StatsView.Affected

    @GraphQL(Covid.Country.todayDeaths)
    var todayDeaths: Int

    @GraphQL(Covid.Country.timeline.cases._forEach(\.value))
    var casesOverTime: [Int]

    var body: some View {
        NeumporphicCard {
            VStack(alignment: .leading) {
                HStack {
                    countryCode.flatMap(emoji(countryCode:)).map { Text($0).font(.title).fontWeight(.bold).foregroundColor(.primary) }
                    Text(self.name).font(.title).fontWeight(.bold).foregroundColor(.primary)
                }

                Spacer()

                Text("\(todayDeaths) people died today in \(name).")
                    .font(.body)
                    .fontWeight(.light)
                    .lineLimit(0)
                    .foregroundColor(.secondary)

                Spacer()

                StatsView(affected: affected).padding(.horizontal, 16).padding(.top, 8)
                LineView(data: casesOverTime.map(Double.init), title: "Timeline", style: ChartStyle.neumorphicColors(), valueSpecifier: "%.0f").frame(height: 340)
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
