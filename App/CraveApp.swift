import SwiftUI
import FirebaseCore
import FirebaseAuth
import Combine

// MARK: - Main App Entry Point
// Firebase Configuration + Authentication State

@main
struct CraveApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                NavBar()
                    .environmentObject(authManager)
            } else {
                OnboardingView()
                    .environmentObject(authManager)
            }
        }
    }
}

// MARK: - Authentication Manager
// Manages user authentication and firebase operations

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var errorMessage: String?
    
    // Listener that monitors authentication state changes
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    // Set up listener on init and remove on deinit to prevent memory leaks
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // Track authentication changes
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                self?.userEmail = user?.email
                self?.userName = user?.displayName
            }
        }
    }
    
    // Signs in user via email and password
    func signInWithEmail(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                withAnimation {
                    self?.isAuthenticated = true
                }
            }
        }
    }
    
    // Creates new user account with email and password
    func signUpWithEmail(email: String, password: String, name: String? = nil) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                if let name = name, let user = authResult?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = name
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("Error updating display name: \(error)")
                        } else {
                            DispatchQueue.main.async {
                                self?.userName = name
                            }
                        }
                    }
                }
                
                withAnimation {
                    self?.isAuthenticated = true
                }
            }
        }
    }
    
    // Signs out the current user
    func signOut() {
        do {
            try Auth.auth().signOut()
            withAnimation {
                isAuthenticated = false
                userEmail = nil
                userName = nil
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error signing out: \(error)")
        }
    }

    // Resets the password on an account
    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
}

// MARK: - Onboarding View
// Handles user registration and login flows

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showEmailInput = false
    @State private var isSignUp = true
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Constants
    private let primaryColor = Color(red: 239/255, green: 68/255, blue: 68/255)
    private let buttonHeight: CGFloat = 56
    private let cornerRadius: CGFloat = 28
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                Spacer()
                
                // Main Content
                VStack(spacing: 32) {
                    heroSection
                    authenticationSection
                    termsSection
                }
                .padding(.horizontal, 24)
                
                Spacer()
                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: authManager.errorMessage) { _, newValue in
            if let error = newValue {
                alertMessage = error
                showAlert = true
                authManager.errorMessage = nil
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image("crave")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    )
                
                Text("Crave")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(primaryColor)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color.white)
                .frame(width: 100, height: 100)
                .overlay(
                    Image("crave")
                        .resizable()
                        .scaledToFit()
                )
            
            VStack(spacing: 8) {
                Text("Welcome to Crave")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Create an account to discover\ndelicious recipes tailored just for you")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var authenticationSection: some View {
        VStack(spacing: 12) {
            if !showEmailInput {
                signInOptionsView
            } else {
                emailFormView
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var signInOptionsView: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring()) {
                    showEmailInput = true
                }
            }) {
                HStack(spacing: 8) {
                    Text("✉️")
                        .font(.system(size: 15))
                    Text("Continue with Email")
                        .font(.system(size: 21, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(primaryColor)
                .cornerRadius(cornerRadius)
            }
            
            Button(action: {
                alertMessage = "Apple Sign In is not currently available"
                showAlert = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Continue with Apple")
                        .font(.system(size: 19, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(Color.black)
                .cornerRadius(cornerRadius)
            }
        }
    }
    
    private var emailFormView: some View {
        VStack(spacing: 12) {
            if isSignUp {
                TextField("Username", text: $username)
                    .textContentType(.username)
                    .padding()
                    .autocapitalization(.none)
                    .frame(height: buttonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    )
            }
            
            TextField("Enter your email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .frame(height: buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
            
            SecureField("Enter your password", text: $password)
                .textContentType(isSignUp ? .newPassword : .password)
                .padding()
                .frame(height: buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
            
            Button(action: handleAuthAction) {
                Text(isSignUp ? "Sign Up" : "Sign In")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: buttonHeight)
                    .background(primaryColor)
                    .cornerRadius(cornerRadius)
            }
            
            Button(action: toggleAuthMode) {
                Text(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up")
                    .font(.system(size: 15))
                    .foregroundColor(primaryColor)
                    .padding(.top, 4)
            }
            
            Button(action: resetForm) {
                Text("Back to options")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
    }
    
    private var termsSection: some View {
        Text("By continuing, you agree to our Terms of Service and Privacy Policy")
            .font(.system(size: 13))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.top, 8)
    }
        
    // Handles sign up or sign in based on current mode
    private func handleAuthAction() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        if isSignUp {
            authManager.signUpWithEmail(email: email, password: password, name: username)
        } else {
            authManager.signInWithEmail(email: email, password: password)
        }
    }
    
    // Toggles between sign up and sign in modes
    private func toggleAuthMode() {
        withAnimation(.spring()) {
            isSignUp.toggle()
        }
    }
    
    // Resets form to initial state
    private func resetForm() {
        withAnimation(.spring()) {
            showEmailInput = false
            isSignUp = true
            email = ""
            password = ""
            username = ""
        }
    }
}

// MARK: - Preview

struct OnboardingViewPreview: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AuthManager())
    }
}
