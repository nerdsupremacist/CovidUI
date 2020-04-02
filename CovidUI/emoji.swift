import Foundation

private let countriesByCode = Dictionary(NSLocale.isoCountryCodes.map { (countryName(for: $0).lowercased(), $0) }) { $1 }

private func countryName(for code: String) -> String {
    return NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.countryCode, value: code) ?? ""
}

func emoji(countryCode: String) -> String {
    return countryCode.uppercased().unicodeScalars.reduce("") { result, item in
        guard let scalar = UnicodeScalar(127397 + item.value) else {
            return result
        }
        return result + String(scalar)
    }
}

func emoji(country: String) -> String? {
    guard let countryCode = countriesByCode[country.lowercased()] else {
        return nil
    }
    return emoji(countryCode: countryCode)
}
