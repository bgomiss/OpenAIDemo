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
}

struct OpenAIResponse: Codable {
    let messages: [Message]
}

class OpenAIService {
    private let apiKey = "YOUR_API_KEY"

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

        let requestBody = OpenAIRequest(
            model: "gpt-4",
            messages: [
                Message(role: "system", content: "You are a programmer's assistant."),
                Message(role: "user", content: prompt)
            ]
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
                let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
                let content = openAIResponse.messages.last?.content
                completion(content)
            } catch {
                print("Failed to decode response: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }
}

