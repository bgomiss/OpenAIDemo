//
//  ContentView.swift
//  OpenAIDemo
//
//  Created by aycan duskun on 19.05.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var responseText: String = "Waiting for response..."
    private let openAIService = OpenAIService()
    
    var body: some View {
        VStack {
            TextField("Enter your prompt here", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                fetchResponse()
            }) {
                Text("Send")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Text(responseText)
                .padding()
            
            Spacer()
        }
        .padding()
    }
    
    private func fetchResponse() {
        openAIService.fetchResponse(prompt: userInput) { response in
            DispatchQueue.main.async {
                responseText = response ?? "Failed to fetch response"
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

