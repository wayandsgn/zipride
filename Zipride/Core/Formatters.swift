import Foundation

/// Every number, price and date in the app goes through pt-BR formatting.
enum BR {
    static let locale = Locale(identifier: "pt_BR")
    static let timeZone = TimeZone(identifier: "America/Fortaleza") ?? .current

    static func money(_ value: Double) -> String {
        value.formatted(.currency(code: "BRL").locale(locale))
    }

    static func km(_ value: Double) -> String {
        let decimals = value >= 10 ? 0 : 1
        let number = value.formatted(.number.precision(.fractionLength(decimals)).locale(locale))
        return "\(number) km"
    }

    static func rating(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2)).locale(locale))
    }

    static func integer(_ value: Int) -> String {
        value.formatted(.number.locale(locale))
    }

    static func time(_ date: Date) -> String {
        var style = Date.FormatStyle(locale: locale, timeZone: timeZone)
        style = style.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)
        return date.formatted(style)
    }

    static func shortDate(_ date: Date) -> String {
        var style = Date.FormatStyle(locale: locale, timeZone: timeZone)
        style = style.day().month(.abbreviated)
        return date.formatted(style)
    }

    static func longDate(_ date: Date) -> String {
        var style = Date.FormatStyle(locale: locale, timeZone: timeZone)
        style = style.weekday(.wide).day().month(.wide)
        return date.formatted(style)
    }

    /// Accent- and case-insensitive key used by search ("acude" finds "Açude").
    static func searchKey(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: locale)
    }
}
