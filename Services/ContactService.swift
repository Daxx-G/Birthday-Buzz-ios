import Foundation
import Contacts

@MainActor
class ContactService: ObservableObject {
    
    enum ContactError: Error {
        case permissionDenied
        case accessRestricted
        case unknown
    }
    
    private let contactStore = CNContactStore()
    
    // TODO: Implement permission request flow
    func requestPermission() async throws {
        // TODO: Request contacts permission
        // TODO: Handle all permission states
        fatalError("TODO: Implement contacts permission request")
    }
    
    // TODO: Implement contacts fetching with birthday filtering
    func fetchContacts() async throws -> [ContactRef] {
        // TODO: Fetch all contacts with required keys
        // TODO: Filter and map to ContactRef models
        // TODO: Handle contacts without names gracefully
        fatalError("TODO: Implement contacts fetching")
    }
    
    // TODO: Implement permission status checking
    var hasPermission: Bool {
        // TODO: Return current authorization status
        fatalError("TODO: Implement permission status check")
    }
    
    // TODO: Implement specific contact fetching by ID
    func contact(with id: String) async throws -> ContactRef? {
        // TODO: Fetch specific contact by identifier
        // TODO: Handle not found cases
        fatalError("TODO: Implement single contact fetch")
    }
}
