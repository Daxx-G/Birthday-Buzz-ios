# BirthdayBuzz iOS - Project Plan

## 1. Feature Specification

### MVP Features
- **Triage Screen**: Pass-through over all Contacts for include/skip decisions
- **Buzz List Screen**: Curated subset of contacts where isBuzzed == true
- **Birthday Entry**: Manual birthday entry for contacts without system birthdays
- **Ask Flow**: SMS-based birthday request with Mail/Share fallbacks
- **Local Notifications**: Annual reminders at 09:00 using UNUserNotificationCenter
- **Settings**: Global notification time, Feb 29 handling

**Acceptance Criteria**:
- Given I open the app, When I first launch, Then I see onboarding for Contacts permissions
- Given I deny Contacts access, When I try to use the app, Then I see permission prompt guidance
- Given I'm on Triage screen, When I swipe right on a contact, Then they're added to Buzz List
- Given I'm viewing a contact without birthday, When I tap actions, Then I see "Enter birthday" and "Ask for birthday"
- Given I set a birthday, When the date arrives, Then I receive notification at configured time
- Given it's a leap year, When Feb 29 birthday occurs, Then notification fires on Feb 29
- Given it's not a leap year, When Feb 29 birthday would occur, Then notification fires on Feb 28

### Later Features
- Multiple reminder times per contact
- Birthday history/notes
- Gift ideas/reminders
- Social integration (Facebook, LinkedIn birthdays)
- Contact groups/categories
- Bulk birthday import
- Widget support
- Siri shortcuts

## 2. Architecture Overview

### Core Components
```
┌─────────────────────────────────────────┐
│                Views                    │
│  OnboardingView │ TriageView │ BuzzView │
│  SettingsView   │ BirthdayEntryView     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│            ViewModels                   │
│  TriageViewModel │ BuzzListViewModel    │
│  SettingsViewModel │ BirthdayViewModel  │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│             Services                    │
│ ContactsService │ NotificationService   │
│ StorageService  │ MessageComposerService│
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│          Data Layer                     │
│  ContactRef     │ BuzzEntry             │
│  UserDefaults   │ ContactStore          │
└─────────────────────────────────────────┘
```

### Key Design Principles
- **MVVM Pattern**: Clean separation of concerns with SwiftUI binding
- **Single Source of Truth**: BuzzEntry holds all user modifications
- **Privacy First**: No network calls, all data stays local
- **Reactive Updates**: Combine publishers for real-time UI updates
- **Permission Graceful**: App functions even with limited permissions

## 3. Data Model & Storage

### Core Models

**ContactRef** (System Contact Mirror)
```swift
struct ContactRef: Identifiable {
    let id: String              // CNContact.identifier
    let fullName: String        // compositeFullName
    let hasSystemBirthday: Bool // birthday != nil
    let systemBirthday: DateComponents? // birthday
}
```

**BuzzEntry** (User Modifications)
```swift
struct BuzzEntry: Identifiable {
    let contactId: String           // Links to ContactRef.id
    var isBuzzed: Bool             // In Buzz List?
    var localBirthday: DateComponents? // User-entered birthday
    var notificationId: String?    // UNNotification identifier
    var lastScheduledAt: Date?     // Last notification schedule time
    var lastRequestDate: Date?     // Last "ask for birthday" attempt
    var requestChannel: String?    // "sms", "mail", "share"
}
```

**effectiveBirthday Logic**
```swift
func effectiveBirthday(contactRef: ContactRef, buzzEntry: BuzzEntry) -> DateComponents? {
    return buzzEntry.localBirthday ?? contactRef.systemBirthday
}
```

### Storage Strategy (MVP)
- **UserDefaults**: BuzzEntry array with Codable
- **Rationale**: Simple, reliable, fits data size (<1000 contacts typical)
- **Migration Path**: Easy to move to CoreData/SQLite if needed

**Later**: CoreData for complex queries, relationships, and sync

## 4. Screens & User Flows

### Onboarding Flow
1. **Welcome Screen**: App description + "Get Started" CTA
2. **Permissions Screen**: Request Contacts access with explanation
3. **Auto-redirect**: To Triage if permissions granted

### Main Navigation (TabView)
1. **Triage Tab**: All contacts, swipe to include/exclude
2. **Buzz List Tab**: Your curated list with birthday status
3. **Settings Tab**: Notification time, preferences

### Screen Details

**TriageView**
- List of all contacts from ContactStore
- Filter: Show non-buzzed contacts first
- Actions: Swipe right (add to buzz), swipe left (skip)
- Birthday indicator: ✅ Has birthday, ❓ Missing birthday

**BuzzListView**
- List of buzzed contacts (isBuzzed == true)
- Sorted by next birthday or alphabetical
- Birthday status: Date or "Missing"
- Actions per contact: Edit birthday, Remove from buzz

**BirthdayEntryView (Modal)**
- Contact name header
- Date picker for birthday (day/month required, year optional)
- Save/Cancel actions
- Validation: Valid date, not future

**SettingsView**
- Notification time picker (default 09:00)
- Feb 29 handling toggle
- Contacts permission status + re-request button
- About/version info

## 5. Ask-for-Birthday Flow

### Primary Flow (SMS)
1. **Trigger**: Tap "Ask for birthday" on contact without birthday
2. **Phone Selection**: If multiple numbers, show picker
3. **Message Compose**: Pre-fill MFMessageComposeViewController
4. **User Action**: User reviews, modifies, sends manually
5. **Tracking**: Record attempt in BuzzEntry.lastRequestDate

### Fallback Flows
**No Phone Number**: Show Mail composer with email
**No Email**: Show Share sheet with message text
**No Communication Methods**: Show alert to manually ask

### UX Copy & Localization
```swift
// Localisation.strings
"ask.title" = "Ask for Birthday"
"ask.phone_picker_title" = "Choose phone number"
"ask.no_phone_title" = "No phone number found"
"ask.no_phone_message" = "Try email or copy message to ask elsewhere"
"ask.success_title" = "Request sent!"
"ask.success_message" = "Remember to update their birthday when they reply"

"msg.ask_template" = "Hey %@ — I'm updating my contacts for close friends/family. What's your birthday (day/month, year optional)?"
"msg.ask_subject" = "Birthday update request"
```

## 6. Edge Cases & Error States

### Permission Scenarios
- **Denied on Launch**: Show explanation + Settings redirect
- **Limited Access**: Work with available contacts, show upgrade prompt
- **Revoked Later**: Graceful degradation, show re-permission UI

### Contact Edge Cases
- **No Name**: Use "Unknown Contact" + ID suffix
- **Multiple Phone Numbers**: Show picker, prefer mobile
- **No Communication Methods**: Disable ask flow, show manual instruction
- **Contact Deleted**: Mark BuzzEntry as orphaned, offer cleanup

### Birthday Validation
- **Feb 29 Non-Leap Year**: Accept but notify about leap year behavior
- **Future Dates**: Prevent with validation message
- **Invalid Dates**: DatePicker handles this naturally

### Notification Edge Cases
- **Permission Denied**: Show explanation, disable features gracefully
- **System Changes**: Re-schedule on app launch/foreground
- **Time Zone Changes**: Use local time zone for consistency

## 7. File & Folder Blueprint

```
Models/
├── ContactRef.swift           ✅ (exists)
├── BuzzEntry.swift           ✅ (exists)
└── AppSettings.swift        // Global settings model

ViewModels/
├── OnboardingViewModel.swift
├── TriageViewModel.swift
├── BuzzListViewModel.swift
├── BirthdayEntryViewModel.swift
└── SettingsViewModel.swift

Views/
├── OnboardingView.swift
├── MainTabView.swift
├── TriageView.swift
├── BuzzListView.swift
├── BirthdayEntryView.swift
├── SettingsView.swift
└── Components/
    ├── ContactRowView.swift
    ├── BirthdayIndicatorView.swift
    └── PermissionPromptView.swift

Services/
├── ContactsService.swift      // CNContactStore wrapper
├── StorageService.swift       // UserDefaults + Codable persistence
├── NotificationService.swift  // UNUserNotificationCenter wrapper
└── MessageComposerService.swift // MFMessageComposeViewController wrapper

Tests/
├── Unit/
│   ├── ContactsServiceTests.swift
│   ├── StorageServiceTests.swift
│   ├── NotificationServiceTests.swift
│   └── ViewModelTests.swift
└── UI/
    ├── OnboardingFlowTests.swift
    ├── TriageFlowTests.swift
    └── BirthdayEntryTests.swift

Resources/
├── Localisation.strings      ✅ (exists)
├── Assets.xcassets
└── Info.plist
```

### Key Service Signatures

**ContactsService**
```swift
class ContactsService: ObservableObject {
    func requestPermission() async -> Bool
    func fetchAllContacts() -> [ContactRef]
    func contact(withId id: String) -> ContactRef?
}
```

**NotificationService**
```swift
class NotificationService {
    func requestPermission() async -> Bool
    func scheduleAnnualNotification(for contact: ContactRef, at time: DateComponents) -> String
    func cancelNotification(id: String)
}
```

**MessageComposerService**
```swift
class MessageComposerService: NSObject, MFMessageComposeViewControllerDelegate {
    func canSendText() -> Bool
    func presentMessageComposer(to phoneNumber: String, body: String, from viewController: UIViewController)
}
```

## 8. Test Plan

### Unit Tests
- **ContactsService**: Permission handling, contact fetching, error states
- **StorageService**: BuzzEntry CRUD, persistence, data integrity
- **NotificationService**: Scheduling, cancellation, Feb 29 logic
- **ViewModels**: State management, user actions, data binding
- **effectiveBirthday**: Logic validation with various input combinations

### UI Tests
- **Onboarding Flow**: Permission requests, navigation flow
- **Triage Flow**: Contact swiping, buzz list addition/removal
- **Birthday Entry**: Date picking, validation, saving
- **Ask Flow**: Message composition, fallback scenarios
- **Settings**: Notification time changes, permission management

### Manual QA Checklist
- [ ] First launch onboarding completes successfully
- [ ] Contacts permission prompt appears and works
- [ ] Triage screen shows all contacts with correct indicators
- [ ] Swipe gestures add/remove contacts from buzz list
- [ ] Birthday entry saves correctly and updates UI
- [ ] Ask flow generates correct message template
- [ ] Notifications fire at configured time
- [ ] Feb 29 birthdays handle leap years correctly
- [ ] Settings changes persist across app launches
- [ ] App gracefully handles permission revocation
- [ ] All error states show appropriate user guidance

## 9. Risk Assessment & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|------------|---------|------------|
| Contacts permission denied | High | High | Clear onboarding explanation, graceful degradation |
| Notification permission denied | Medium | Medium | Show impact explanation, offer manual reminders |
| iOS Contacts API changes | Low | High | Wrap in service layer, comprehensive testing |
| UserDefaults data corruption | Low | Medium | Add data validation, backup/restore capability |
| Message composer crashes | Medium | Low | Comprehensive error handling, fallback options |
| Performance with large contact lists | Medium | Medium | Pagination, background processing, lazy loading |
| Timezone/DST notification issues | Medium | High | Use local timezone consistently, test edge cases |
| App Store rejection | Low | High | Follow HIG strictly, test on multiple devices |

### Key Mitigations
- **Service Layer Pattern**: Isolate external dependencies
- **Comprehensive Error Handling**: User-friendly error messages
- **Graceful Degradation**: Core functionality works with limited permissions
- **Extensive Testing**: Unit, UI, and manual testing coverage

## 10. Work Breakdown (GitHub Issues)

### Phase 1: Foundation (Week 1-2)
**Issue #1: Core Data Models & Services** (L)
- Implement ContactsService with CNContactStore integration
- Create StorageService with UserDefaults persistence
- Add comprehensive unit tests
- AC: Can fetch contacts, persist BuzzEntry, handle permissions

**Issue #2: Basic Navigation & Onboarding** (M)
- Create MainTabView with placeholder screens
- Implement OnboardingView with permission requests
- Add OnboardingViewModel with state management
- AC: App launches, requests permissions, navigates correctly

### Phase 2: Core Features (Week 3-4)
**Issue #3: Triage Screen Implementation** (L)
- Build TriageView with contact list and swipe gestures
- Implement TriageViewModel with buzz list management
- Add ContactRowView component with birthday indicators
- AC: Can see all contacts, swipe to add/remove from buzz list

**Issue #4: Buzz List Screen** (M)
- Create BuzzListView showing curated contacts
- Implement sorting by next birthday
- Add remove/edit actions per contact
- AC: Shows only buzzed contacts with birthday status

**Issue #5: Birthday Entry System** (M)
- Build BirthdayEntryView modal with date picker
- Add validation and save/cancel functionality
- Implement BirthdayEntryViewModel
- AC: Can add/edit birthdays, data persists correctly

### Phase 3: Advanced Features (Week 5-6)
**Issue #6: Notification System** (L)
- Implement NotificationService with UNUserNotificationCenter
- Add annual birthday scheduling with Feb 29 logic
- Create notification permission handling
- AC: Notifications fire at correct times, handle edge cases

**Issue #7: Ask-for-Birthday Flow** (M)
- Build MessageComposerService with SMS/Mail/Share fallbacks
- Add phone number selection for multiple options
- Implement tracking of request attempts
- AC: Can send birthday requests through multiple channels

**Issue #8: Settings Screen** (S)
- Create SettingsView with notification time picker
- Add permission status and re-request functionality
- Implement settings persistence
- AC: Settings save and affect app behavior

### Phase 4: Polish & Testing (Week 7-8)
**Issue #9: Comprehensive Testing Suite** (M)
- Add full unit test coverage for services and view models
- Create UI tests for critical user flows
- Implement manual QA checklist
- AC: >90% test coverage, all flows tested

**Issue #10: Error Handling & Edge Cases** (S)
- Add graceful permission handling throughout app
- Implement all error states with user guidance
- Add data validation and corruption recovery
- AC: App handles all identified edge cases gracefully

**Issue #11: Localization & Accessibility** (S)
- Complete Localisation.strings for all user-facing text
- Add accessibility labels and hints
- Test with VoiceOver and large text
- AC: App fully accessible and ready for localization

### Phase 5: App Store Preparation (Week 9)
**Issue #12: Final Polish & Submission** (S)
- App Store screenshots and metadata
- Final device testing and performance optimization
- Privacy policy and App Store review preparation
- AC: App ready for App Store submission

**Labels:**
- MVP: Issues #1-8 (required for core functionality)
- Nice: Issues #9-12 (quality and polish)

**Estimates:**
- S (Small): 1-2 days
- M (Medium): 3-5 days  
- L (Large): 5-8 days

**Total Estimate**: 8-9 weeks for complete MVP with polish
