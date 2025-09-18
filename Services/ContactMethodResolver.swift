import Foundation
import Contacts

class ContactMethodResolver {
    
    enum ContactMethod {
        case phone(String)
        case email(String)
        case none
    }
    
    enum ResolverError: Error {
        case noValidMethods
        case contactNotFound
    }
    
    // TODO: Implement best contact method resolution
    func resolveBestContactMethod(for contactId: String) async throws -> ContactMethod {
        // TODO: Fetch contact with phone numbers and email addresses
        // TODO: Prioritize mobile phone over other phones
        // TODO: Prioritize primary email over other emails
        // TODO: Return phone over email if both available
        // TODO: Return .none if no valid methods found
        fatalError("TODO: Implement best contact method resolution")
    }
    
    // TODO: Implement all available contact methods fetching
    func resolveAllContactMethods(for contactId: String) async throws -> [ContactMethod] {
        // TODO: Fetch contact with all phone numbers and emails
        // TODO: Filter out invalid/empty values
        // TODO: Return sorted array (phones first, then emails)
        fatalError("TODO: Implement all contact methods resolution")
    }
    
    // TODO: Implement contact method validation
    private func isValidPhone(_ phone: String) -> Bool {
        // TODO: Basic phone number validation
        // TODO: Remove formatting and check for minimum length
        fatalError("TODO: Implement phone validation")
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        // TODO: Basic email validation using regex or built-in validator
        fatalError("TODO: Implement email validation")
    }
    
    // TODO: Implement contact method formatting
    private func formatPhoneNumber(_ phone: String) -> String {
        // TODO: Clean and format phone number for display/use
        fatalError("TODO: Implement phone number formatting")
    }
    
    // TODO: Implement contact method prioritization
    private func prioritizePhoneNumbers(_ phones: [CNPhoneNumber]) -> [String] {
        // TODO: Sort by label priority (mobile, iPhone, main, work, home, other)
        // TODO: Filter duplicates and invalid numbers
        fatalError("TODO: Implement phone number prioritization")
    }
    
    private func prioritizeEmails(_ emails: [CNLabeledValue<NSString>]) -> [String] {
        // TODO: Sort by label priority (home, work, other)
        // TODO: Filter duplicates and invalid emails
        fatalError("TODO: Implement email prioritization")
    }
}
