//
//  ApiViewModel.swift
//  ApiCalledSUI
//
//  Created by Guru Mahan on 30/12/22.
//

import Foundation
class ApiViewModel: ObservableObject {
    
    @Published var isSelected:innerData?
    @Published var dataList : ApiModel?
    var jsonvalue = [innerData]()
    var link = "https://datausa.io/api/data?drilldowns=Nation&measures=Population"
    
    /**
     Asynchronously loads data from a given URL, decodes it into an `ApiModel`, and stores it in SQLite.
     
     - Important: The function handles invalid URL errors, networking errors, and decoding errors. If data is successfully retrieved, it is stored in the database.
     - Throws: Prints error messages if the URL is invalid, data retrieval fails, or decoding fails.
     - SeeAlso: `storeSQLiteData(apiModel:)`, `fetchSQLiteData()`
     */
    func loadData() async {
        guard let url = URL(string: link) else {
            print("Invalid URL:", link)
            return
        }
        
        do {
            // Fetch data from the URL
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check for valid HTTP response status
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid HTTP response status code.")
                return
            }
            
            // Decode the data into an ApiModel object
            do {
                let decodedResponse = try JSONDecoder().decode(ApiModel.self, from: data)
                
                // Store the decoded data in SQLite and then fetch it
                DispatchQueue.main.async {
                    self.storeSQLiteData(apiModel: decodedResponse)
                    self.fetchSQLiteData()
                }
            } catch {
                print("Decoding error:", error.localizedDescription)
                self.fetchSQLiteData()  // Fallback to fetch any existing data
            }
            
        } catch {
            print("Data retrieval error:", error.localizedDescription)
            self.fetchSQLiteData()  // Fallback to fetch any existing data
        }
    }
    
    /// A reference to the shared `SQDBHelper` instance for database operations.
    let dbHelper = SQDBHelper.shared

    /**
     Stores the provided `ApiModel` data in the SQLite database.
     
     - Parameter apiModel: The `ApiModel` object to be stored in the database.
     - Note: This function directly calls the `insertApiModel` method from `SQDBHelper` to save the data.
     - SeeAlso: `SQDBHelper.insertApiModel(_:)`
     */
    func storeSQLiteData(apiModel: ApiModel) {
        dbHelper.insertApiModel(apiModel)
    }

    /**
     Fetches the stored `ApiModel` data from the SQLite database.
     
     - Note: This function retrieves the `ApiModel` from the database, updates `dataList` and `jsonvalue` properties, and prints the retrieved model for verification.
     - Important: Ensure `SQDBHelper.fetchApiModel()` is correctly implemented to return an `ApiModel` object if data exists.
     - SeeAlso: `SQDBHelper.fetchApiModel()`
     */
    func fetchSQLiteData() {
        if let retrievedApiModel = dbHelper.fetchApiModel() {
            // Update instance properties with the retrieved data
            self.dataList = retrievedApiModel
            self.jsonvalue = retrievedApiModel.data
            print("Retrieved ApiModel:", retrievedApiModel)
        } else {
            print("No data found in SQLite.")
        }
    }
}
