import Foundation
import SwiftUI

@MainActor
class TriageViewModel: ObservableObject {
    
    @Published var contacts: [ContactRef] = []
    @Published var currentContactIndex = 0
    @Published var isLoading = false
    @Published var hasPermission = false
    @Published var errorMessage: String?
    @Published var triageCompleted = false
    
    private let contactService: ContactService
    private let storageService: StorageService
    
    init(contactService: ContactService = ContactService(), storageService: StorageService = StorageService()) {
        self.contactService = contactService
        self.storageService = storageService
    }
    
    var currentContact: ContactRef? {
        guard currentContactIndex < contacts.count else { return nil }
        return contacts[currentContactIndex]
    }
    
    var progress: Double {
        guard !contacts.isEmpty else { return 0 }
        return Double(currentContactIndex) / Double(contacts.count)
    }
    
    // Implement contacts loading with permission check
    func loadContacts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // For now, use mock data until ContactService is implemented
            // TODO: Replace with actual ContactService call
            let mockContacts = [
                ContactRef(id: "1", fullName: "Alice Johnson", hasSystemBirthday: true, systemBirthday: DateComponents(month: 3, day: 15)),
                ContactRef(id: "2", fullName: "Bob Smith", hasSystemBirthday: false, systemBirthday: nil),
                ContactRef(id: "3", fullName: "Carol Davis", hasSystemBirthday: true, systemBirthday: DateComponents(month: 7, day: 22)),
                ContactRef(id: "4", fullName: "David Wilson", hasSystemBirthday: false, systemBirthday: nil),
                ContactRef(id: "5", fullName: "Emily Brown", hasSystemBirthday: true, systemBirthday: DateComponents(month: 12, day: 3)),
                ContactRef(id: "6", fullName: "Frank Miller", hasSystemBirthday: false, systemBirthday: nil),
                ContactRef(id: "7", fullName: "Grace Lee", hasSystemBirthday: true, systemBirthday: DateComponents(month: 5, day: 18)),
                ContactRef(id: "8", fullName: "Henry Taylor", hasSystemBirthday: false, systemBirthday: nil)
            ]
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            await MainActor.run {
                self.contacts = mockContacts
                self.isLoading = false
                self.hasPermission = true
            }
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load contacts"
                handleError(error)
            }
        }
    }
    
    // Implement contact inclusion (swipe right/tap include)
    func includeCurrentContact() async {
        guard let currentContact = currentContact else { return }
        
        // TODO: Create BuzzEntry for current contact and save to StorageService
        // For now, just move to next contact
        print("✅ Including contact: \(currentContact.fullName)")
        
        await MainActor.run {
            moveToNextContact()
        }
    }
    
    // Implement contact skipping (swipe left/tap skip)
    func skipCurrentContact() {
        guard let currentContact = currentContact else { return }
        
        print("⏭️ Skipping contact: \(currentContact.fullName)")
        moveToNextContact()
    }
    
    // Implement navigation to next contact
    private func moveToNextContact() {
        currentContactIndex += 1
        
        if currentContactIndex >= contacts.count {
            triageCompleted = true
            print("🎉 Triage completed!")
        }
    }
    
    // Implement permission request
    func requestPermission() async {
        // For now, simulate permission granted
        // TODO: Use actual ContactService.requestPermission()
        
        // Simulate permission request delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            hasPermission = true
            print("📱 Contacts permission granted (simulated)")
        }
    }
    
    // TODO: Implement triage restart
    func restartTriage() async {
        // TODO: Reset current index
        // TODO: Reload contacts
        // TODO: Reset completion state
        fatalError("TODO: Implement triage restart")
    }
    
    // TODO: Implement error handling
    private func handleError(_ error: Error) {
        // TODO: Convert error to user-friendly message
        // TODO: Update errorMessage state
        // TODO: Log error for debugging
        fatalError("TODO: Implement error handling")
    }
}
