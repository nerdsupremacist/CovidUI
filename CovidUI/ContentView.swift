
import SwiftUI
import FancyScrollView
import SwiftUICharts

struct ContentView: View {
    let api: Covid

    @GraphQL(Covid.myCountry)
    var currentCountry: FeaturedCountryCell.Country?

    @GraphQL(Covid.myCountry.name)
    var currentCountryName

    @GraphQL(Covid.myCountry.news)
    var currentCountryNews: [NewsStoryCell.NewsStory]?

    @GraphQL(Covid.world)
    var world: CurrentStateCell.World

    @GraphQL(Covid.world.timeline.cases.graph._forEach(\.value))
    var cases

    @GraphQL(Covid.world.news)
    var news: [NewsStoryCell.NewsStory]

    @GraphQL(Covid.countries)
    var countries: Paging<BasicCountryCell.Country>

    @GraphQL(Covid.countries.edges._forEach(\.node)._compactMap()._withDefault([]))
    var pins: [CountryMapPin]

    var body: some View {
        NavigationView {
            ZStack {
                Background().edgesIgnoringSafeArea(.all)
                
                FancyScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            Text(L10n.Headline.disease)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Spacer()

                            Text(L10n.hashtag)
                                .font(.callout)
                                .fontWeight(.light)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)

                        currentCountry.map { country in
                            VStack(alignment: .leading) {
                                Text(L10n.Headline.recommendations).font(.title).fontWeight(.medium).foregroundColor(.primary)
                                FeaturedCountryCell(api: api, country: country)
                            }
                            .padding(.horizontal, 16)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            currentCountryName.map { name in
                                Text(L10n.Headline.Country.news(name))
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                            }

                            currentCountryNews.map { news in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .center) {
                                        Spacer()

                                        ForEach(news, id: \.title) { news in
                                            NewsStoryCell(newsStory: news).frame(width: 280, height: 340).padding(.vertical, 16).padding(.horizontal, 8)
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text(L10n.Headline.world)
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)

                            CurrentStateCell(world: world)
                                .padding(.horizontal, 16)

                            NeumporphicCard {
                                LineView(
                                    data: cases.map(Double.init),
                                    title: L10n.Headline.cases,
                                    style: ChartStyle.neumorphicColors(),
                                    valueSpecifier: "%.0f"
                                )
                                .frame(height: 340)
                                .padding([.horizontal, .bottom], 16)
                            }
                            .padding(.horizontal, 16)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text(L10n.Headline.news)
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .center) {
                                    Spacer()

                                    ForEach(news, id: \.title) { news in
                                        NewsStoryCell(newsStory: news).frame(width: 280, height: 340).padding(.vertical, 16).padding(.horizontal, 8)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text(L10n.Headline.map)
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)

                            MapView(pins: pins).frame(height: 400)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text(L10n.Headline.countries)
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)

                            ForEach(countries.values, id: \.name) { country in
                                VStack {
                                    Divider()
                                    BasicCountryCell(api: self.api, country: country)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
    }
}
