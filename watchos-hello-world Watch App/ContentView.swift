//
//  ContentView.swift
//  watchos-hello-world Watch App
//
//  Created by keckadmin on 9/12/23.
//

import SwiftUI
import Combine

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}

struct ContentView: View {
    
    @State private var results = [Result]()
    @State private var savedDate: String = ""
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            
            Button("Save Data") {
                saveToiCloud()
            }
            
            Text("Last saved: \(savedDate)")
            
            List(results, id: \.trackId) { item in
                VStack(alignment: .leading) {
                    Text(item.trackName)
                        .font(.headline)
                    Text(item.collectionName)
                }
            }
            .task {
                await loadData()
            }
        }
        .padding()
    }
    
    // Save to iCloud example
    func saveToiCloud() {
        let cloudStore = NSUbiquitousKeyValueStore.default
        let currentDate = Date().description
        cloudStore.set(currentDate, forKey: "sampleData")
        cloudStore.synchronize()
        self.savedDate = currentDate
    }
    
    // Load from iCloud example
    func loadDataFromiCloud() {
        let cloudStore = NSUbiquitousKeyValueStore.default
        if let date = cloudStore.string(forKey: "sampleData") {
            self.savedDate = date
        }
    }
    
    // Load data from REST API example
    func loadData() async {
        guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=song") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                results = decodedResponse.results
            }
        } catch {
            print("Invalid data")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
