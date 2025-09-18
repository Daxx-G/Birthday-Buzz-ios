import Foundation

struct ContactRef: Identifiable {
    let id: String
    let fullName: String
    let hasSystemBirthday: Bool
    let systemBirthday: DateComponents?
}
