//
//  SQDBHelper.swift
//  SQL_LiteLocalStroage_POC
//
//  Created by Guru Mahan on 04/11/24.
//

import SwiftUI
import SQLite3

/**
 A singleton helper class to manage SQLite database operations in the app.
 - Note: This class provides methods for opening, closing, and executing SQL queries, specifically targeting the storage of data in the `ApiModel` table.
 */
class SQDBHelper {
    
    /**
     Singleton instance of `SQDBHelper` to be used across the app.
     */
    static let shared = SQDBHelper()

    /**
     A pointer to the SQLite database, allowing low-level interaction with SQLite.
     */
    var db: OpaquePointer?

    /**
     Initializes the `SQDBHelper` instance.
     
     - Note: The initializer is private to enforce singleton usage. It opens or creates the database file and creates the `ApiModel` table if it doesn’t already exist.
     */
    private init() {
        db = openDatabase()
        createApiModelTable()
    }
    
    /**
     Opens or creates the SQLite database file.
     
     - Returns: An optional `OpaquePointer` to the opened database, or `nil` if the operation fails.
     - Important: This method must be called to initialize the `db` pointer before any other database operations.
     - Note: The database file is stored in the app's document directory with the filename `ApiModelDatabase.sqlite`.
     - SeeAlso: `closeDatabase()`
     */
    func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("ApiModelDatabase.sqlite")

        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("Successfully opened database at \(fileURL.path)")
            return db
        } else {
            print("Unable to open database.")
            return nil
        }
    }
    
    /**
     Closes the connection to the database.
     
     - Note: Should be called when database operations are complete to release any resources.
     */
    func closeDatabase() {
        sqlite3_close(db)
    }

    /**
     Creates the `ApiModel` table in the database if it does not already exist.
     
     - Important: This table contains two columns:
       - `id`: An INTEGER primary key that auto-increments.
       - `data`: A BLOB column used to store binary data.
     - SeeAlso: `executeQuery(_:)`
     */
    func createApiModelTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS ApiModel (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data BLOB
        );
        """
        executeQuery(createTableQuery)
    }

    /**
     Executes a given SQL query on the database.
     
     - Parameter query: The SQL statement to be executed.
     - Note: Used to perform table creation and other SQL operations.
     - SeeAlso: `createApiModelTable()`
     */
    func executeQuery(_ query: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully executed query.")
            } else {
                print("Could not execute query.")
            }
        } else {
            print("Query could not be prepared.")
        }
        sqlite3_finalize(statement)
        print("sqlite3_finalize")
    }
}

extension SQDBHelper {
    
    /**
     Inserts an `ApiModel` object into the `ApiModel` table in the database.
     
     - Parameter model: The `ApiModel` instance to be stored in the database.
     - Note: The `ApiModel` instance is encoded as JSON data and stored in the `data` column as a BLOB.
     - Important: Ensure that `ApiModel` conforms to `Codable` so it can be encoded to JSON.
     - Throws: Prints an error message if encoding to JSON fails or if the SQL statement cannot be prepared.
     - SeeAlso: `ApiModel`, `sqlite3_bind_blob`
     */
    func insertApiModel(_ model: ApiModel) {
        let insertQuery = "INSERT OR REPLACE INTO ApiModel (data) VALUES (?);"
        var statement: OpaquePointer?

        // Encode `ApiModel` to JSON `Data`
        do {
            let jsonData = try JSONEncoder().encode(model)

            if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
                // Bind the JSON data as a BLOB
                sqlite3_bind_blob(statement, 1, (jsonData as NSData).bytes, Int32(jsonData.count), nil)

                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Successfully inserted ApiModel.")
                } else {
                    print("Could not insert ApiModel.")
                }
            } else {
                print("Insert ApiModel statement could not be prepared.")
            }
        } catch {
            print("Failed to encode ApiModel to JSON:", error)
        }
        sqlite3_finalize(statement)
    }
}

extension SQDBHelper {
    
    /**
     Fetches the first `ApiModel` record from the `ApiModel` table in the database.
     
     - Returns: An optional `ApiModel` instance. Returns `nil` if no data is found or if decoding fails.
     - Note: This function retrieves the data stored in the `data` column as a BLOB, decodes it from JSON, and returns an `ApiModel` object.
     - Important: Ensure that `ApiModel` conforms to `Codable` so it can be decoded from JSON.
     - Throws: Prints an error message if decoding fails or if the SQL statement cannot be prepared.
     - SeeAlso: `ApiModel`, `sqlite3_column_blob`
     */
    func fetchApiModel() -> ApiModel? {
        let query = "SELECT data FROM ApiModel LIMIT 1;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                // Retrieve the BLOB data from the database
                if let dataPointer = sqlite3_column_blob(statement, 0) {
                    let dataSize = Int(sqlite3_column_bytes(statement, 0))
                    let data = Data(bytes: dataPointer, count: dataSize)
                    
                    // Decode the JSON data into an `ApiModel` instance
                    do {
                        let apiModel = try JSONDecoder().decode(ApiModel.self, from: data)
                        return apiModel
                    } catch {
                        print("Failed to decode JSON:", error)
                    }
                }
            } else {
                print("No ApiModel found.")
            }
        } else {
            print("Fetch ApiModel statement could not be prepared.")
        }
        sqlite3_finalize(statement)
        return nil
    }
}

