
import Foundation
import SwiftUI
import FancyScrollView
import URLImage
import SwiftUICharts

struct CountryDetailView: View {
    @GraphQL(Covid.country.name)
    var name: String

    @GraphQL(Covid.country.info.iso2)
    var countryCode: String?

    @GraphQL(Covid.country.affected)
    var affected: StatsView.Affected

    @GraphQL(Covid.country.todayCases)
    var casesToday: Int

    @GraphQL(Covid.country.todayDeaths)
    var deathsToday: Int

    @GraphQL(Covid.country.timeline.cases._forEach(\.value))
    var casesOverTime: [Int]

    @GraphQL(Covid.country.timeline.deaths._forEach(\.value))
    var deathsOverTime: [Int]

    @GraphQL(Covid.country.timeline.recovered._forEach(\.value))
    var recoveredOverTime: [Int]

    @GraphQL(Covid.country.news._forEach(\.image))
    var images: [String?]

    @GraphQL(Covid.country.news)
    var news: [NewsStoryCell.NewsStory]

    var title: String {
        return [countryCode.flatMap(emoji(countryCode:)), name].compactMap { $0 }.joined(separator: " ")
    }

    var body: some View {
        ZStack {
            Background().edgesIgnoringSafeArea(.all)

            FancyScrollView(title: title, header: {
                images.compactMap { $0 }.first.flatMap(URL.init(string:)).map { url in
                    URLImage(url, placeholder: { _ in AnyView(Text("")) }) { proxy in
                        AnyView(
                            proxy.image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        )
                    }
                }
            }) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        NeumporphicCard {
                            HStack {
                                Spacer()
                                VStack {
                                    Text("Cases").font(.headline).fontWeight(.bold).foregroundColor(.primary)
                                    Text(casesToday.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
                                }

                                Spacer()
                                Divider().padding(.vertical, 8)
                                Spacer()

                                VStack {
                                    Text("Deaths").font(.headline).fontWeight(.bold).foregroundColor(.primary)
                                    Text(deathsToday.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 24)
                        }
                        .padding(.horizontal, 16)
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Total")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        NeumporphicCard {
                            StatsView(affected: affected)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 24)
                        }
                        .padding(.horizontal, 16)
                    }

                    NeumporphicCard {
                        LineView(data: casesOverTime.map(Double.init), title: "Cases", style: ChartStyle.neumorphicColors(), valueSpecifier: "%.0f")
                            .frame(height: 340)
                            .padding([.horizontal, .bottom], 16)
                    }
                    .padding(.horizontal, 16)

                    NeumporphicCard {
                        LineView(data: deathsOverTime.map(Double.init), title: "Deaths", style: ChartStyle.neumorphicColors(), valueSpecifier: "%.0f")
                            .frame(height: 340)
                            .padding([.horizontal, .bottom], 16)
                    }
                    .padding(.horizontal, 16)

                    NeumporphicCard {
                        LineView(data: recoveredOverTime.map(Double.init), title: "Recovered", style: ChartStyle.neumorphicColors(), valueSpecifier: "%.0f")
                            .frame(height: 340)
                            .padding([.horizontal, .bottom], 16)
                    }
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("News")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)

                        ForEach(news, id: \.title) { news in
                            NewsStoryCell(newsStory: news).frame(height: 380).padding(.horizontal, 16)
                        }
                    }
                }
                .background(Background())
            }
        }
    }
}
