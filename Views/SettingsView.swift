import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    
    var body: some View {
        NavigationView {
            List {
                // TODO: Implement notifications section
                notificationsSection
                
                // TODO: Implement data section
                dataSection
                
                // TODO: Implement app info section
                appInfoSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.loadSettings()
        }
        .alert("Clear All Data", isPresented: $viewModel.showingClearConfirmation) {
            // TODO: Implement clear confirmation alert
            clearDataAlert
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    // TODO: Implement notifications section
    private var notificationsSection: some View {
        Section("Notifications") {
            // TODO: Notification permission status
            HStack {
                Text("Permission")
                Spacer()
                if viewModel.hasNotificationPermission {
                    Text("Granted")
                        .foregroundColor(.green)
                } else {
                    Button("Request") {
                        Task {
                            await viewModel.requestNotificationPermission()
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            // TODO: Notification time picker
            DatePicker(
                "Reminder Time",
                selection: .constant(timeFromComponents(viewModel.notificationTime)),
                displayedComponents: [.hourAndMinute]
            )
            .onChange(of: timeFromComponents(viewModel.notificationTime)) { newTime in
                let components = DateComponents(
                    hour: Calendar.current.component(.hour, from: newTime),
                    minute: Calendar.current.component(.minute, from: newTime)
                )
                Task {
                    await viewModel.updateNotificationTime(components)
                }
            }
            
            // TODO: Reschedule all button
            Button("Reschedule All Notifications") {
                Task {
                    await viewModel.rescheduleAllNotifications()
                }
            }
        }
    }
    
    // TODO: Implement data section
    private var dataSection: some View {
        Section("Data Management") {
            // TODO: Stats display
            HStack {
                Text("Buzz List Entries")
                Spacer()
                Text("\(viewModel.totalBuzzEntries)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Scheduled Notifications")
                Spacer()
                Text("\(viewModel.scheduledNotifications)")
                    .foregroundColor(.secondary)
            }
            
            // TODO: Export data button
            Button("Export Data") {
                Task {
                    await viewModel.exportData()
                }
            }
            .disabled(viewModel.isExporting)
            
            // TODO: Import data button
            Button("Import Data") {
                showingImportPicker = true
            }
            
            // TODO: Clear all data button
            Button("Clear All Data") {
                viewModel.showingClearConfirmation = true
            }
            .foregroundColor(.red)
        }
    }
    
    // TODO: Implement app info section
    private var appInfoSection: some View {
        Section("App Information") {
            HStack {
                Text("Version")
                Spacer()
                Text(viewModel.appVersion)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text(viewModel.buildNumber)
                    .foregroundColor(.secondary)
            }
            
            // TODO: Add links to privacy policy, support, etc.
            Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            Link("Support", destination: URL(string: "https://example.com/support")!)
        }
    }
    
    // TODO: Implement clear data confirmation alert
    private var clearDataAlert: some View {
        Group {
            Button("Clear", role: .destructive) {
                Task {
                    await viewModel.clearAllData()
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // TODO: Implement time conversion helper
    private func timeFromComponents(_ components: DateComponents) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: components) ?? Date()
    }
}

#Preview {
    SettingsView()
}
