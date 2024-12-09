// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import Foundation
import Testing

@testable import WordCards

@MainActor
struct ContactsFeatureTests {
//    @Test
//    func addFlow() async {
//        let store = TestStore(initialState: ContactsFeature.State()) {
//            ContactsFeature()
//
//        } withDependencies: {
//            $0.uuid = .incrementing
//        }
//
//        await store.send(.addButtonTapped) {
//            $0.destination = .addContact(
//                AddContactFeature.State(
//                    contact: Contact(id: UUID(0), name: "")
//                )
//            )
//        }
//
//        await store.send(\.destination.addContact.setName, "Blob Jr.") {
//            $0.destination?.addContact?.contact.name = "Blob Jr."
//        }
//
//        await store.send(\.destination.addContact.setName, "Blob Jr.") {
//            $0.destination?.addContact?.contact.name = "Blob Jr."
//        }
//
//        await store.send(\.destination.addContact.saveButtonTapped)
//
//        await store.receive(
//            \.destination.addContact.delegate.saveContact,
//            Contact(id: UUID(0), name: "Blob Jr.")
//        ) {
//            $0.contacts = [
//                Contact(id: UUID(0), name: "Blob Jr."),
//            ]
//        }
//
//        await store.receive(\.destination.dismiss) {
//            $0.destination = nil
//        }
//    }
//
//
//    @Test
//    func addFlowNonExhaustive() async {
//        let store = TestStore(initialState: ContactsFeature.State()) {
//            ContactsFeature()
//        } withDependencies: {
//            $0.uuid = .incrementing
//        }
//
//        store.exhaustivity = .off
//
//        await store.send(.addButtonTapped)
//        await store.send(\.destination.addContact.setName, "Blob Jr.")
//        await store.send(\.destination.addContact.saveButtonTapped)
//        await store.skipReceivedActions()
//
//        store.assert {
//            $0.contacts = [
//                Contact(id: UUID(0), name: "Blob Jr."),
//            ]
//            $0.destination = nil
//        }
//    }

    @Test
    func deleteContact() async {
        let store = TestStore(
            initialState: ContactsFeature.State(
                contacts: [
                    Contact(id: UUID(0), name: "Carlo"),
                    Contact(id: UUID(1), name: "Marco"),
                ]
            ),
            reducer: {
                ContactsFeature()
            }
        )

        await store.send(.deleteButtonTapped(id: UUID(0))) {
            $0.destination = .alert(.deleteConfirmation(id: UUID(0)))
        }

        await store.send(.destination(.presented(.alert(.confirmDeletion(id: UUID(1)))))) {
            $0.contacts.remove(id: UUID(1))
            $0.destination = nil
        }
    }
}
