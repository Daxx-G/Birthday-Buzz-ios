import Foundation

struct BuzzEntry: Identifiable, Codable {
    let id = UUID()
    let contactId: String
    var isBuzzed: Bool
    var localBirthday: DateComponents?
    var notificationId: String?
    var lastScheduledAt: Date?
    var lastRequestDate: Date?
    var requestChannel: String?
    
    enum CodingKeys: String, CodingKey {
        case id, contactId, isBuzzed, localBirthday, notificationId, lastScheduledAt, lastRequestDate, requestChannel
    }
}
