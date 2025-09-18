import SwiftUI

struct BuzzListView: View {
    
    @StateObject private var viewModel = BuzzListViewModel()
    @State private var showingBirthdayEntry = false
    @State private var selectedContactId: String?
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.buzzEntries.isEmpty {
                    emptyStateView
                } else {
                    buzzEntriesList
                }
            }
            .navigationTitle("Buzz List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Settings") {
                        showingSettings = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schedule All") {
                        Task {
                            await viewModel.scheduleAllNotifications()
                        }
                    }
                    .disabled(viewModel.isSchedulingAll)
                }
            }
        }
        .task {
            await viewModel.loadBuzzEntries()
        }
        .sheet(isPresented: $showingBirthdayEntry) {
            if let contactId = selectedContactId {
                BirthdayEntryView(contactId: contactId) { birthday in
                    Task {
                        await viewModel.enterBirthday(for: contactId, birthday: birthday)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // TODO: Implement empty state view
    private var emptyStateView: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Buzz List Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add contacts to your buzz list to get birthday reminders")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Add Contacts") {
                // TODO: Present triage flow
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // TODO: Implement buzz entries list
    private var buzzEntriesList: some View {
        List {
            ForEach(viewModel.buzzEntries, id: \.contactId) { entry in
                BuzzEntryRow(
                    entry: entry,
                    onEnterBirthday: {
                        selectedContactId = entry.contactId
                        showingBirthdayEntry = true
                    },
                    onAskForBirthday: {
                        Task {
                            await viewModel.askForBirthday(contactId: entry.contactId)
                        }
                    },
                    onScheduleNotification: {
                        Task {
                            await viewModel.scheduleNotification(for: entry.contactId)
                        }
                    }
                )
            }
            .onDelete(perform: deleteEntries)
        }
        .refreshable {
            await viewModel.loadBuzzEntries()
        }
    }
    
    // TODO: Implement entry deletion
    private func deleteEntries(offsets: IndexSet) {
        // TODO: Remove entries at offsets
        // TODO: Call viewModel.removeContact for each
    }
}

// TODO: Implement buzz entry row view
struct BuzzEntryRow: View {
    let entry: BuzzEntry
    let onEnterBirthday: () -> Void
    let onAskForBirthday: () -> Void
    let onScheduleNotification: () -> Void
    
    @State private var contactName = "Loading..."
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(contactName)
                    .font(.headline)
                
                // TODO: Display entry status
                Text(entryStatusText)
                    .font(.caption)
                    .foregroundColor(entryStatusColor)
                
                // TODO: Display days until birthday if available
                if let days = daysUntilBirthday {
                    Text("\(days) days until birthday")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // TODO: Action buttons based on entry state
            entryActionButtons
        }
        .padding(.vertical, 4)
        .task {
            // TODO: Load contact name
        }
    }
    
    // TODO: Implement status text computation
    private var entryStatusText: String {
        // TODO: Return appropriate status based on entry state
        "TODO: Implement status"
    }
    
    // TODO: Implement status color computation
    private var entryStatusColor: Color {
        // TODO: Return appropriate color based on status
        .secondary
    }
    
    // TODO: Implement days until birthday computation
    private var daysUntilBirthday: Int? {
        // TODO: Calculate from entry.localBirthday
        nil
    }
    
    // TODO: Implement action buttons
    private var entryActionButtons: some View {
        HStack(spacing: 8) {
            if entry.localBirthday == nil {
                Button("Enter", action: onEnterBirthday)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                
                Button("Ask", action: onAskForBirthday)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            } else if entry.notificationId == nil {
                Button("Schedule", action: onScheduleNotification)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
    }
}

#Preview {
    BuzzListView()
}
