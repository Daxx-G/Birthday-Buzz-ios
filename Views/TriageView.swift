import SwiftUI

struct TriageView: View {
    
    @StateObject private var viewModel = TriageViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var cardOffset = CGSize.zero
    @State private var showingBuzzList = false
    @State private var cardRotation = 0.0
    @State private var cardScale = 1.0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress indicator
                progressView
                
                // Main content area
                GeometryReader { geometry in
                    ZStack {
                        if viewModel.triageCompleted {
                            completionView
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let contact = viewModel.currentContact {
                            // Stack multiple cards for depth effect
                            ForEach(0..<min(3, viewModel.contacts.count - viewModel.currentContactIndex), id: \.self) { index in
                                let contactIndex = viewModel.currentContactIndex + index
                                if contactIndex < viewModel.contacts.count {
                                    let contact = viewModel.contacts[contactIndex]
                                    contactCardView(contact)
                                        .scaleEffect(index == 0 ? cardScale : 0.95 - Double(index) * 0.02)
                                        .offset(
                                            x: index == 0 ? cardOffset.width : 0,
                                            y: CGFloat(index * 4)
                                        )
                                        .rotationEffect(.degrees(index == 0 ? cardRotation : 0))
                                        .zIndex(Double(10 - index))
                                        .opacity(index == 0 ? 1.0 : 0.8 - Double(index) * 0.2)
                                }
                            }
                        } else if viewModel.isLoading {
                            loadingView
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            errorView
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Action buttons
                if !viewModel.triageCompleted && viewModel.currentContact != nil {
                    actionButtons
                        .opacity(cardOffset == .zero ? 1.0 : 0.6)
                        .animation(.easeInOut(duration: 0.2), value: cardOffset)
                }
            }
            .padding()
            .navigationTitle("Build Your Buzz List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.loadContacts()
        }
        .fullScreenCover(isPresented: $showingBuzzList) {
            BuzzListView()
        }
    }
    
    // Progress indicator
    private var progressView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Building your Buzz List")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(viewModel.currentContactIndex) of \(viewModel.contacts.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 2)
        }
    }
    
    // Contact card view with swipe gestures
    private func contactCardView(_ contact: ContactRef) -> some View {
        VStack(spacing: 24) {
            // Contact avatar placeholder
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(String(contact.fullName.prefix(2)).uppercased())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Contact name
            Text(contact.fullName)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // Birthday status
            HStack {
                Image(systemName: contact.hasSystemBirthday ? "calendar.badge.checkmark" : "calendar.badge.exclamationmark")
                    .foregroundColor(contact.hasSystemBirthday ? .green : .orange)
                
                Text(contact.hasSystemBirthday ? "Has birthday in Contacts" : "No birthday in Contacts")
                    .font(.subheadline)
                    .foregroundColor(contact.hasSystemBirthday ? .green : .orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(contact.hasSystemBirthday ? .green.opacity(0.1) : .orange.opacity(0.1))
            )
            
            Spacer()
            
            // Swipe instructions with visual indicators
            VStack(spacing: 12) {
                HStack {
                    HStack {
                        Image(systemName: "hand.draw")
                            .foregroundColor(.red)
                        Text("Skip")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("Include")
                            .font(.caption)
                            .foregroundColor(.green)
                        Image(systemName: "hand.draw")
                            .foregroundColor(.green)
                            .scaleEffect(x: -1) // Flip horizontally
                    }
                }
                
                Text("Swipe or tap buttons")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .opacity(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            // Swipe feedback overlay
            Group {
                if cardOffset.width > 50 {
                    // Include overlay
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.green.opacity(0.3))
                        .overlay(
                            VStack {
                                Image(systemName: "heart.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.green)
                                Text("INCLUDE")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        )
                        .opacity(Double(cardOffset.width / 100))
                } else if cardOffset.width < -50 {
                    // Skip overlay
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.red.opacity(0.3))
                        .overlay(
                            VStack {
                                Image(systemName: "xmark")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                Text("SKIP")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                        )
                        .opacity(Double(-cardOffset.width / 100))
                }
            }
        )
        .scaleEffect(cardScale)
        .offset(cardOffset)
        .rotationEffect(.degrees(cardRotation))
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
                        cardOffset = value.translation
                        cardRotation = Double(value.translation.width / 10)
                        cardScale = 1.0 - abs(Double(value.translation.width)) / 1000
                    }
                }
                .onEnded { value in
                    handleSwipe(value.translation)
                }
        )
    }
    
    // TODO: Implement completion view
    private var completionView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Triage Complete!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("You've reviewed all your contacts. Ready to manage your buzz list?")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("View Buzz List") {
                showingBuzzList = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // TODO: Implement loading view
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Loading contacts...")
                .foregroundColor(.secondary)
        }
    }
    
    // TODO: Implement error view
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Unable to load contacts")
                .font(.headline)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            Button("Try Again") {
                Task {
                    await viewModel.loadContacts()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // Action buttons
    private var actionButtons: some View {
        HStack(spacing: 40) {
            // Skip button
            Button {
                animateCardAction {
                    viewModel.skipCurrentContact()
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Skip")
                        .font(.caption)
                }
                .foregroundColor(.red)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            Circle()
                                .stroke(Color.red.opacity(0.3), lineWidth: 2)
                        )
                )
            }
            .scaleEffect(cardOffset.width < -50 ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: cardOffset.width < -50)
            
            // Include button  
            Button {
                animateCardAction {
                    Task {
                        await viewModel.includeCurrentContact()
                    }
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Include")
                        .font(.caption)
                }
                .foregroundColor(.green)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .overlay(
                            Circle()
                                .stroke(Color.green.opacity(0.3), lineWidth: 2)
                        )
                )
            }
            .scaleEffect(cardOffset.width > 50 ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: cardOffset.width > 50)
        }
    }
    
    // Swipe gesture handling
    private func handleSwipe(_ translation: CGSize) {
        let threshold: CGFloat = 100
        let velocity = abs(translation.width)
        
        if translation.width > threshold || (translation.width > 50 && velocity > 500) {
            // Swipe right - include contact
            animateCardExit(direction: .right) {
                Task {
                    await viewModel.includeCurrentContact()
                }
            }
        } else if translation.width < -threshold || (translation.width < -50 && velocity > 500) {
            // Swipe left - skip contact
            animateCardExit(direction: .left) {
                viewModel.skipCurrentContact()
            }
        } else {
            // Snap back to center
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                cardOffset = .zero
                cardRotation = 0
                cardScale = 1.0
            }
        }
    }
    
    // Animate card action (for button taps)
    private func animateCardAction(_ action: @escaping () -> Void) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            cardScale = 0.95
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                cardScale = 1.0
            }
            action()
        }
    }
    
    // Animate card exit
    private func animateCardExit(direction: SwipeDirection, completion: @escaping () -> Void) {
        let exitOffset: CGFloat = direction == .right ? 500 : -500
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            cardOffset = CGSize(width: exitOffset, height: -100)
            cardRotation = direction == .right ? 15 : -15
            cardScale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion()
            
            // Reset card state for next contact
            cardOffset = .zero
            cardRotation = 0
            cardScale = 1.0
        }
    }
    
    enum SwipeDirection {
        case left, right
    }
}

#Preview {
    TriageView()
}
