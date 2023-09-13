//
//  ContentView.swift
//  watchos-hello-world Watch App
//
//  Created by keckadmin on 9/12/23.
//

import SwiftUI
import CloudKit
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
                let currentDate = Date().description
                saveToiCloud()
                saveToCloudKit(content: "Hello, CloudKit!")
                saveToCloudKit(content: currentDate)
                
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
    
    // Save to CloudKit example
    func saveToCloudKit(content: String) {
        // Reference to public database
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        // Create a new record
        let newRecord = CKRecord(recordType: "SampleData")
        newRecord["content"] = content as CKRecordValue
        
        // Save the record to iCloud
        publicDatabase.save(newRecord) { (record, error) in
            if let error = error {
                // Handle the error
                print("Error saving to CloudKit: \(error.localizedDescription)")
            } else {
                print("Saved to CloudKit!")
            }
        }
    }
    
    // Load from CloudKit example
    func loadFromCloudKit(completion: @escaping ([CKRecord]?, Error?) -> Void) {
        // Reference to the public database
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        // Create a query to fetch all 'SampleData' records
        let query = CKQuery(recordType: "SampleData", predicate: NSPredicate(value: true))
        
        // Perform the fetch with the new method
        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { result in
            switch result {
            case .success(let data):
                let records = data.matchResults.compactMap { (recordID, recordResult) -> CKRecord? in
                    switch recordResult {
                    case .success(let record):
                        return record
                    case .failure(_):
                        return nil
                    }
                }
                completion(records, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
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
