//
//  ContentView.swift
//  OpenAIDemo
//
//  Created by aycan duskun on 19.05.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var conversation: [Message] = [Message(role: "system", content: "Welcome To CHATGPT.")]
    private let openAIService = OpenAIService()
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(conversation, id: \.content) { message in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(message.role.capitalized + ":")
                                .font(.headline)
                                .foregroundColor(message.role == "user" ? .blue : .green)
                            Text(message.content)
                                .padding()
                                .background(Color.gray .opacity(0.2))
                                .cornerRadius(8)
                             }
                             Spacer() // This will push the content to the left
                         }
                 .padding(.vertical, 4)
                }
            }
            
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
            
            
        }
        .padding()
    }
    
    private func fetchResponse() {
           let userMessage = Message(role: "user", content: userInput)
           conversation.append(userMessage)
           
           openAIService.fetchResponse(prompt: userInput) { response in
               DispatchQueue.main.async {
                   if let responseContent = response {
                       let assistantMessage = Message(role: "assistant", content: responseContent)
                       conversation.append(assistantMessage)
                   } else {
                       let errorMessage = Message(role: "assistant", content: "Failed to fetch response")
                       conversation.append(errorMessage)
                   }
                   userInput = ""
               }
           }
       }
   }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

