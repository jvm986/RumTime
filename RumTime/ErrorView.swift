//
//  ErrorView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI

struct ErrorView: View {
    let errorWrapper: ErrorWrapper
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                    .padding(.bottom)
                    .accessibilityHidden(true)

                Text("An error has occurred!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)

                Text(errorWrapper.error.localizedDescription)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(errorWrapper.guidance)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 4)

                if let retryAction = errorWrapper.retryAction {
                    Button(action: {
                        dismiss()
                        retryAction()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Retry")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .accessibilityLabel("Retry")
                    .accessibilityHint("Attempts to retry the failed operation")
                    .padding(.top, 20)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    enum SampleError: Error {
        case errorRequired
    }
    
    static var wrapper: ErrorWrapper {
        ErrorWrapper(error: SampleError.errorRequired,
                     guidance: "You can safely ignore this error.")
    }
    
    static var previews: some View {
        ErrorView(errorWrapper: wrapper)
    }
}

