import SwiftUI

struct OnboardingView: View {
    
    @StateObject private var triageViewModel = TriageViewModel()
    @State private var currentStep = 0
    @State private var showingTriage = false
    @State private var isRequestingPermission = false
    
    private let onboardingSteps = [
        OnboardingStep(
            title: "Welcome to Birthday Buzz",
            description: "Never forget a birthday again! Curate your buzz list and get timely reminders.",
            imageName: "party.popper.fill",
            color: .blue
        ),
        OnboardingStep(
            title: "Privacy First",
            description: "Your data stays on your device. We never access or share your personal information.",
            imageName: "lock.shield.fill",
            color: .green
        ),
        OnboardingStep(
            title: "Permission Required",
            description: "We need access to your contacts to help you create your buzz list.",
            imageName: "person.2.fill",
            color: .orange
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Step indicator dots
                stepIndicator
                    .padding(.top, 60)
                
                // Main content area
                VStack(spacing: 40) {
                    onboardingStepView
                    
                    Spacer()
                    
                    navigationButtons
                }
                .padding()
            }
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, onboardingSteps[currentStep].color.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .fullScreenCover(isPresented: $showingTriage) {
            TriageView()
        }
    }
    
    // Step indicator dots
    private var stepIndicator: some View {
        HStack(spacing: 12) {
            ForEach(0..<onboardingSteps.count, id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? onboardingSteps[currentStep].color : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .scaleEffect(index == currentStep ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
    }
    
    // Onboarding step view
    private var onboardingStepView: some View {
        let currentStepData = onboardingSteps[currentStep]
        
        return VStack(spacing: 30) {
            // Icon
            Image(systemName: currentStepData.imageName)
                .font(.system(size: 80))
                .foregroundColor(currentStepData.color)
                .padding(.top, 20)
            
            // Title and description
            VStack(spacing: 16) {
                Text(currentStepData.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(currentStepData.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .id(currentStep) // Force view recreation for smooth transitions
    }
    
    // Navigation buttons
    private var navigationButtons: some View {
        HStack {
            // Previous button
            if currentStep > 0 {
                Button("Previous") {
                    withAnimation(.easeInOut) {
                        previousStep()
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            // Next/Get Started button
            Button {
                if currentStep == onboardingSteps.count - 1 {
                    Task {
                        await requestPermissionAndStartTriage()
                    }
                } else {
                    withAnimation(.easeInOut) {
                        nextStep()
                    }
                }
            } label: {
                HStack {
                    if isRequestingPermission {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    }
                    
                    Text(currentStep == onboardingSteps.count - 1 ? "Get Started" : "Next")
                }
                .frame(minWidth: 120)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRequestingPermission)
        }
    }
    
    // Step navigation
    private func nextStep() {
        if currentStep < onboardingSteps.count - 1 {
            currentStep += 1
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    // Permission request and triage launch
    private func requestPermissionAndStartTriage() async {
        isRequestingPermission = true
        
        do {
            await triageViewModel.requestPermission()
            
            // Small delay for better UX
            try await Task.sleep(nanoseconds: 500_000_000)
            
            if triageViewModel.hasPermission {
                // Mark onboarding as complete and show triage
                NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
                showingTriage = true
            } else {
                // Handle permission denied - could show an alert or different flow
                // For now, just reset the loading state
                isRequestingPermission = false
            }
        } catch {
            // Handle error
            isRequestingPermission = false
        }
    }
}

// Onboarding step model
struct OnboardingStep {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

#Preview {
    OnboardingView()
}
