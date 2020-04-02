
import SwiftUI
import FancyScrollView
import SwiftUICharts

struct ContentView: View {
    @GraphQL(Covid.myCountry)
    var currentCountry: FeaturedCountryCell.Country?

    @GraphQL(Covid.myCountry.name)
    var currentCountryName: String?

    @GraphQL(Covid.myCountry.news)
    var currentCountryNews: [NewsStoryCell.NewsStory]?

    @GraphQL(Covid.world)
    var world: CurrentStateCell.World

    @GraphQL(Covid.world.timeline.cases._forEach(\.value))
    var cases: [Int]

    @GraphQL(Covid.world.timeline.deaths._forEach(\.value))
    var deaths: [Int]

    @GraphQL(Covid.world.timeline.recovered._forEach(\.value))
    var recovered: [Int]

    @GraphQL(Covid.world.news)
    var news: [NewsStoryCell.NewsStory]

    @GraphQL(Covid.countries)
    var countries: [BasicCountryCell.Country]

    var body: some View {
        NavigationView {
            ZStack {
                Background().edgesIgnoringSafeArea(.all)
                
                FancyScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Covid-19")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)

                        currentCountry.map { country in
                            VStack(alignment: .leading) {
                                Text("For You").font(.title).fontWeight(.medium).foregroundColor(.primary)
                                FeaturedCountryCell(country: country)
                            }
                            .padding(.horizontal, 16)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            currentCountryName.map { name in
                                Text("News in \(name)")
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

                        Text("Around the World")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)

                        CurrentStateCell(world: world)
                            .padding(.horizontal, 16)

                        NeumporphicCard {
                            LineView(data: cases.map(Double.init), title: "Cases", style: ChartStyle.neumorphicColors(), valueSpecifier: "%.0f")
                                .frame(height: 340)
                                .padding([.horizontal, .bottom], 16)
                        }
                        .padding(.horizontal, 16)

                        Text("News")
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

                        Text("Countries")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)

                        ForEach(countries, id: \.name) { country in
                            VStack {
                                Divider()
                                BasicCountryCell(country: country)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}
