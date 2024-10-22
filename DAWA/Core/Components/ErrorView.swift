import SwiftUI

struct ErrorView: View {
    let errorMessage: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Oops!")
                .font(.headline)
                .foregroundColor(Color.theme.primaryText)
                .padding(.top, 20)
            
            Text(errorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.theme.secondaryText)
                .padding(.horizontal)
            
            Button(action: onDismiss) {
                Text("Dismiss")
                    .font(.body)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.appTheme)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color.theme.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .frame(maxWidth: 300)
        .padding(.horizontal)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(errorMessage: "This is an error message", onDismiss: {})
            .background(Color.theme.background)
    }
}
