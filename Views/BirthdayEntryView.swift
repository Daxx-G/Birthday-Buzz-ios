import SwiftUI

struct BirthdayEntryView: View {
    
    let contactId: String
    let onSave: (DateComponents) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var contactName = "Loading..."
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // TODO: Add contact info header
                contactHeader
                
                // TODO: Implement date picker
                birthdayDatePicker
                
                Spacer()
                
                // TODO: Add save button
                saveButton
            }
            .padding()
            .navigationTitle("Enter Birthday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadContactName()
        }
    }
    
    // TODO: Implement contact header
    private var contactHeader: some View {
        VStack(spacing: 10) {
            // TODO: Add contact avatar placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            
            Text(contactName)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("When is their birthday?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // TODO: Implement birthday date picker
    private var birthdayDatePicker: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Birthday")
                .font(.headline)
            
            DatePicker(
                "Birthday",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            
            // TODO: Show selected date in readable format
            Text("Selected: \(dateFormatter.string(from: selectedDate))")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // TODO: Implement save button
    private var saveButton: some View {
        Button {
            saveBirthday()
        } label: {
            Text("Save Birthday")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.blue)
                .cornerRadius(12)
        }
    }
    
    // TODO: Implement birthday saving
    private func saveBirthday() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: selectedDate)
        
        // TODO: Add year if needed for leap year handling
        var birthdayComponents = DateComponents()
        birthdayComponents.month = components.month
        birthdayComponents.day = components.day
        
        onSave(birthdayComponents)
        dismiss()
    }
    
    // TODO: Implement contact name loading
    private func loadContactName() async {
        // TODO: Load contact name from ContactService
        // TODO: Update contactName state
        // TODO: Handle loading errors gracefully
    }
}

#Preview {
    BirthdayEntryView(contactId: "sample-id") { _ in
        // Preview action
    }
}
