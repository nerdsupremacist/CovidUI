
import Foundation
import SwiftUI
import FancyScrollView
import URLImage
import SwiftUICharts

struct CountryDetailView: View {
    @GraphQL(Covid.country.name)
    var name

    @GraphQL(Covid.country.info.emoji)
    var emoji

    @GraphQL(Covid.country.iAffected)
    var affected: StatsView.IAffected

    @GraphQL(Covid.country.todayCases)
    var casesToday

    @GraphQL(Covid.country.todayDeaths)
    var deathsToday

    @GraphQL(Covid.country.timeline.cases.graph._forEach(\.value))
    var casesOverTime

    @GraphQL(Covid.country.timeline.deaths.graph._forEach(\.value))
    var deathsOverTime

    @GraphQL(Covid.country.timeline.recovered.graph._forEach(\.value))
    var recoveredOverTime

    @GraphQL(Covid.country.news._forEach(\.image))
    var images

    @GraphQL(Covid.country.news)
    var news: [NewsStoryCell.NewsStory]

    var title: String {
        return [emoji, name].compactMap { $0 }.joined(separator: " ")
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
                        Text(L10n.Headline.today)
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        NeumporphicCard {
                            HStack {
                                Spacer()
                                VStack {
                                    Text(L10n.Headline.cases).font(.headline).fontWeight(.bold).foregroundColor(.primary)
                                    Text(casesToday.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
                                }

                                Spacer()
                                Divider().padding(.vertical, 8)
                                Spacer()

                                VStack {
                                    Text(L10n.Headline.deaths).font(.headline).fontWeight(.bold).foregroundColor(.primary)
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
                        Text(L10n.Headline.total)
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        NeumporphicCard {
                            StatsView(iAffected: affected)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 24)
                        }
                        .padding(.horizontal, 16)
                    }

                    NeumporphicCard {
                        LineView(
                            data: casesOverTime.map(Double.init),
                            title: L10n.Headline.cases,
                            style: ChartStyle.neumorphicColors(),
                            valueSpecifier: "%.0f"
                        )
                        .frame(height: 340)
                        .padding([.horizontal, .bottom], 16)
                    }
                    .padding(.horizontal, 16)

                    NeumporphicCard {
                        LineView(
                            data: deathsOverTime.map(Double.init),
                            title: L10n.Headline.deaths,
                            style: ChartStyle.neumorphicColors(),
                            valueSpecifier: "%.0f"
                        )
                        .frame(height: 340)
                        .padding([.horizontal, .bottom], 16)
                    }
                    .padding(.horizontal, 16)

                    NeumporphicCard {
                        LineView(
                            data: recoveredOverTime.map(Double.init),
                            title: L10n.Headline.recovered,
                            style: ChartStyle.neumorphicColors(),
                            valueSpecifier: "%.0f"
                        )
                        .frame(height: 340)
                        .padding([.horizontal, .bottom], 16)
                    }
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 16) {
                        Text(L10n.Headline.news)
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
