//
//  ContactsManager.swift
//  PhoneInternationaliser
//
//  Created by Ayden Panhuyzen on 16/04/2022.
//

import Foundation
import Contacts

class ContactsManager {
    private let store = CNContactStore()

    func requestAccess(completionHandler: @escaping (Bool, Error?) -> Void) {
        return store.requestAccess(for: .contacts, completionHandler: completionHandler)
    }

    var authorizationStatus: CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }

    var canRead: Bool {
        return authorizationStatus == .authorized
    }

    func enumerateContacts(_ block: @escaping (CNContact) -> Void) throws {
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        return try store.enumerateContacts(with: request) { contact, _ in block(contact) }
    }

    func update(contact: CNMutableContact) throws {
        let request = CNSaveRequest()
        request.update(contact)
        try store.execute(request)
    }
}

