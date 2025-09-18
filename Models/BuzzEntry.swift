import Foundation

struct BuzzEntry: Identifiable {
    let contactId: String
    var isBuzzed: Bool
    var localBirthday: DateComponents?
    var notificationId: String?
    var lastScheduledAt: Date?
    var lastRequestDate: Date?
    var requestChannel: String?
}
