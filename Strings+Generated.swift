// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// #stayhome
  internal static let hashtag = L10n.tr("Languages", "hashtag")

  internal enum Cases {
    /// Plural format key: "%#@cases@"
    internal static func number(_ p1: Int) -> String {
      return L10n.tr("Languages", "cases.number", p1)
    }
  }

  internal enum Country {
    /// Plural format key: "%#@deaths@ died in %@ today."
    internal static func deaths(_ p1: Int, _ p2: Any) -> String {
      return L10n.tr("Languages", "country.deaths", p1, String(describing: p2))
    }
  }

  internal enum Deaths {
    /// Plural format key: "%#@deaths@"
    internal static func number(_ p1: Int) -> String {
      return L10n.tr("Languages", "deaths.number", p1)
    }
  }

  internal enum Headline {
    /// Cases
    internal static let cases = L10n.tr("Languages", "headline.cases")
    /// Countries
    internal static let countries = L10n.tr("Languages", "headline.countries")
    /// Deaths
    internal static let deaths = L10n.tr("Languages", "headline.deaths")
    /// COVID-19
    internal static let disease = L10n.tr("Languages", "headline.disease")
    /// Map
    internal static let map = L10n.tr("Languages", "headline.map")
    /// News
    internal static let news = L10n.tr("Languages", "headline.news")
    /// For You
    internal static let recommendations = L10n.tr("Languages", "headline.recommendations")
    /// Recovered
    internal static let recovered = L10n.tr("Languages", "headline.recovered")
    /// Timeline
    internal static let timeline = L10n.tr("Languages", "headline.timeline")
    /// Today
    internal static let today = L10n.tr("Languages", "headline.today")
    /// Total
    internal static let total = L10n.tr("Languages", "headline.total")
    /// Around the World
    internal static let world = L10n.tr("Languages", "headline.world")
    internal enum Country {
      /// News in %@
      internal static func news(_ p1: Any) -> String {
        return L10n.tr("Languages", "headline.country.news", String(describing: p1))
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
