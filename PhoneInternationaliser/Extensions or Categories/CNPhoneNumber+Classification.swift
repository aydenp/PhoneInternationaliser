//
//  CNPhoneNumber+IsLocal.swift
//  PhoneInternationaliser
//
//  Created by Ayden Panhuyzen on 16/04/2022.
//

import Foundation
import Contacts

extension CNPhoneNumber {
    var isSpecialPhoneNumber: Bool {
        let digitsWithoutDialingCode = digitsRemovingDialingCode()
        return digitsWithoutDialingCode.hasPrefix("#") || digitsWithoutDialingCode.hasPrefix("*") || digitsWithoutDialingCode.count < 7
    }

    func isLocalPhoneNumber(inRegionWithDialingCode dialingCode: String) -> Bool {
        let dialingCodeWithoutPlus = dialingCode.replacingOccurrences(of: "+", with: "")
        let digitsWithoutDialingCode = digitsRemovingDialingCode()
        return !isSpecialPhoneNumber && !digitsWithoutDialingCode.hasPrefix(dialingCodeWithoutPlus) && digits == digitsWithoutDialingCode
    }

    func convertedToInternationalPhoneNumber(inRegionWithISOCode regionISOCode: String) -> CNPhoneNumber? {
        let dialingCode = CNPhoneNumber.dialingCode(forISOCountryCode: regionISOCode)
        guard !dialingCode.isEmpty, isLocalPhoneNumber(inRegionWithDialingCode: dialingCode) else { return nil }
        return CNPhoneNumber(digits: dialingCode + digits, countryCode: regionISOCode)
    }
}

