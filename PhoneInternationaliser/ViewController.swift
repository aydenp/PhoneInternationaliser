//
//  ViewController.swift
//  PhoneInternationaliser
//
//  Created by Ayden Panhuyzen on 2022-04-16.
//

import AppKit
import Contacts

class ViewController: NSViewController {
    @IBOutlet weak var countryPicker: NSPopUpButton!
    @IBOutlet var logArea: LogReceivingTextView!
    @IBOutlet weak var performButton: NSButton!
    let contactsManager = ContactsManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register log area to receive future log messages
        UserLogger.shared.register(receiver: logArea)
        userLog("Welcome!")
        loadCountries()
        checkContactsAccess()
    }

    @IBAction func performButtonClicked(_ sender: NSButton) {
        guard let selectedCountry = countryPicker.selectedItem?.representedObject as? CallingCountry else { return }

        if !contactsManager.canRead {
            contactsManager.requestAccess { (success, error) in
                if !success {
                    userError("We didn't get contacts access. Error: \(error?.localizedDescription ?? "none")")
                }
                DispatchQueue.main.async {
                    self.checkContactsAccess()
                }
            }
            return
        }

        sender.isEnabled = false
        userLog("Starting…")

        try! contactsManager.enumerateContacts { contact in
            var didChangePhoneNumbers = false

            let newPhoneNumbers = contact.phoneNumbers.map { (phoneNumberValue) -> CNLabeledValue<CNPhoneNumber> in
                // Check if local, and convert to an international number
                guard phoneNumberValue.value.isLocalPhoneNumber(inRegionWithDialingCode: selectedCountry.callingCode),
                      let intlPhoneNumber = phoneNumberValue.value.convertedToInternationalPhoneNumber(inRegionWithISOCode: selectedCountry.isoCode) else { return phoneNumberValue }

                let contactName = CNContactFormatter.string(from: contact, style: .fullName) ?? contact.identifier
                let label = phoneNumberValue.label.map { type(of: phoneNumberValue).localizedString(forLabel: $0) } ?? "unlabelled"

                userLog("Converting \(contactName)'s local \(label) phone number to international: \(phoneNumberValue.value.formattedStringValue()) -> \(intlPhoneNumber.formattedStringValue())")

                didChangePhoneNumbers = true
                return phoneNumberValue.settingValue(intlPhoneNumber)
            }

            if didChangePhoneNumbers {
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                mutableContact.phoneNumbers = newPhoneNumbers
                do {
                    try self.contactsManager.update(contact: mutableContact)
                } catch let error {
                    userError("Couldn't update above contact: \(error.localizedDescription)")
                }
            }
        }

        sender.isEnabled = true
    }

    private func loadCountries() {
        for country in CallingCountry.allCountries {
            let item = countryPicker.menu?.addItem(withTitle: country.description, action: nil, keyEquivalent: "")

            // To make sure keyboard nav still works despite the flags in the dropdown text, we prefix it with the country name again at 0.01pt font size (so its effectively invisible) 
            let attributedTitle = NSMutableAttributedString(string: country.name + country.description)
            attributedTitle.addAttribute(.font, value: NSFont.systemFont(ofSize: 0.01), range: NSRange(location: 0, length: country.name.count))
            item?.attributedTitle = attributedTitle

            item?.representedObject = country
        }

        // Select the user's current country
        if let currentIndex = CallingCountry.indexOfCurrentCountry {
            countryPicker.selectItem(at: currentIndex)
        }
    }

    private func checkContactsAccess() {
        switch contactsManager.authorizationStatus {
        case .notDetermined:
            performButton.title = "Grant Access"
            performButton.isEnabled = true
            userInfo("Contacts access needed. Click Grant Access to give permission.")
        case .denied, .restricted:
            performButton.isEnabled = false
            performButton.title = "Cannot Proceed"
            userError("Either you or some restriction (Parental Controls, MDM, etc.) denied contacts access.")
        case .authorized:
            userInfo("Nice! We have contacts access.")
            performButton.title = "Update Contacts"
            performButton.isEnabled = true
        @unknown default: break
        }
    }
}
