
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

    @GraphQL(Covid.Country.cases)
    var cases: Int

    @GraphQL(Covid.Country.deaths)
    var deaths: Int

    @GraphQL(Covid.Country.recovered)
    var recovered: Int

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

                HStack {
                    VStack {
                        Text("Cases").font(.headline).fontWeight(.bold).foregroundColor(.primary).layoutPriority(100)
                        Text(cases.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
                    }

                    Spacer()
                    Divider().padding(.vertical, 8)
                    Spacer()

                    VStack {
                        Text("Deaths").font(.headline).fontWeight(.bold).foregroundColor(.primary).layoutPriority(100)
                        Text(deaths.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
                    }

                    Spacer()
                    Divider().padding(.vertical, 8)
                    Spacer()

                    VStack {
                        Text("Recovered").font(.headline).fontWeight(.bold).foregroundColor(.primary).layoutPriority(100)
                        Text(recovered.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
                    }
                }.padding(.horizontal, 16).padding(.top, 8)
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

extension Int {
    var statFormatted: String {
        return Double(self).statFormatted
    }
}

extension Double {
    var statFormatted: String {

        if self >= 1000, self <= 999999 {
            return String(format: "%.1fK", locale: Locale.current,self/1000).replacingOccurrences(of: ".0", with: "")
        }

        if self > 999999 {
            return String(format: "%.1fM", locale: Locale.current,self/1000000).replacingOccurrences(of: ".0", with: "")
        }

        return String(format: "%.0f", locale: Locale.current,self)
    }
}
