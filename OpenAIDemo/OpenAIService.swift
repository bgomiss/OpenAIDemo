//
//  OpenAIService.swift
//  OpenAIDemo
//
//  Created by aycan duskun on 19.05.2024.
//

import Foundation

struct Message: Codable {
    let role: String
    let content: String
}

struct OpenAIRequest: Codable {
    let model: String
    let messages: [Message]
    let temperature: Double
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        
        let message: Message
        let finish_reason: String
    }
    
    let id: String
    let object: String
    let created: Int
    let model: String
    let usage: Usage
    let choices: [Choice]
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

struct OpenAIError: Codable {
    let message: String
    let type: String
    let param: String?
    let code: String?
}

struct OpenAIErrorResponse: Codable {
    let error: OpenAIError
}

class OpenAIService {
    private let apiKey = API.apiKey
    private var conversationHistory: [Message] = [Message(role: "system", content: "You are a programmer's assistant")]
    
    func fetchResponse(prompt: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Add the user's new message to the conversation history
        conversationHistory.append(Message(role: "user", content: prompt))

        let requestBody = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: conversationHistory,
            temperature: 0.7
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Failed to encode request body: \(error)")
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            // Log the raw response data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                
                if let errorResponse = try? decoder.decode(OpenAIErrorResponse.self, from: data) {
                    print("Error response: \(errorResponse.error.message)")
                    completion("Error: \(errorResponse.error.message)")
                    return
                }
                
                let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
                if let assistantMessage = openAIResponse.choices.first?.message {
                    // Convert the response message to the request message type
                   let message = Message(role: assistantMessage.role, content: assistantMessage.content)
                   // Add the assistant's response to the conversation history
                   self.conversationHistory.append(message)
                   completion(assistantMessage.content)
                    
                } else {
                    completion(nil)
                }
                
            } catch {
                print("Failed to decode response: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }
}
