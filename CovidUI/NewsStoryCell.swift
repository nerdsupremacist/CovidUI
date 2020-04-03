
import Foundation
import Neumorphic
import SwiftUI
import URLImage

struct NewsStoryCell: View {
    @GraphQL(Covid.NewsStory.source.name)
    var source: String

    @GraphQL(Covid.NewsStory.title)
    var title: String

    @GraphQL(Covid.NewsStory.overview)
    var overview: String?

    @GraphQL(Covid.NewsStory.image)
    var image: String?

    @GraphQL(Covid.NewsStory.url)
    var url: String

    var body: some View {
        Button(action: { UIApplication.shared.open(URL(string: self.url)!) }) {
            GeometryReader { geometry in
                NeumporphicCard {
                    ZStack {
                        self.image.flatMap(URL.init(string:)).map { url in
                            URLImage(url, placeholder: { _ in AnyView(Text("")) }) { proxy in
                                AnyView(
                                    proxy.image
                                        .resizable()
                                        .renderingMode(.original)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                )
                            }
                        }

                        VStack(alignment: .leading) {
                            Spacer()
                            ZStack {
                                CardGradient().opacity(0.8).clipShape(RoundedRectangle(cornerRadius: 20))

                                VStack(alignment: .leading) {
                                    Spacer()
                                    Text(self.source).font(.callout).fontWeight(.light).foregroundColor(.secondary)
                                    Text(self.title).font(.headline).fontWeight(.bold).foregroundColor(.primary)
                                    self.overview.map { Text($0).font(.body).fontWeight(.regular).lineLimit(3).foregroundColor(.secondary) }
                                }.padding(.all, 16)
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .buttonStyle(CustomButtonStyle())
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration
            .label
            .animation(nil)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.1))
    }
}

struct CardGradient: View {
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    var body: some View {
        let neumorphic = Neumorphic(colorScheme: colorScheme)
        return LinearGradient(gradient: Gradient(colors: [Color.clear, neumorphic.mainColor(), neumorphic.mainColor()]), startPoint: .top, endPoint: .bottom)
    }
}
