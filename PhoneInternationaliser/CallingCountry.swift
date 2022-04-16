//
//  Countries.swift
//  PhoneInternationaliser
//
//  Created by Ayden Panhuyzen on 2022-04-16.
//

import Foundation

struct CallingCountry {
    static let allCountries = Locale.isoRegionCodes
        .compactMap { CallingCountry(isoCode: $0) }
        .sorted { $0.name < $1.name }
    static let indexOfCurrentCountry = Locale.current.regionCode.flatMap { isoCode in
        allCountries.firstIndex { $0.isoCode == isoCode }.map { Int($0) }
    }

    init?(isoCode: String) {
        self.isoCode = isoCode
        self.callingCode = CNPhoneNumber.dialingCode(forISOCountryCode: isoCode)
        guard !callingCode.isEmpty else { return nil }
    }

    let isoCode, callingCode: String

    var name: String {
        return Locale.current.localizedString(forRegionCode: isoCode) ?? isoCode
    }

    var description: String {
        return "\(flagEmoji) \(name) (\(callingCode))"
    }

    var flagEmoji: String {
        // originally from https://stackoverflow.com/a/30403199
        let base : UInt32 = 127397
        var s = ""
        for v in isoCode.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}
