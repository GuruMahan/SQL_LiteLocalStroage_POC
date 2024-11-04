//
//  SQDBHelper.swift
//  SQL_LiteLocalStroage_POC
//
//  Created by Guru Mahan on 04/11/24.
//

import SwiftUI
import SQLite3

class SQDBHelper {
    static let shared = SQDBHelper()
    var db: OpaquePointer?

    private init() {
        db = openDatabase()
        createApiModelTable()
    }

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
    
    func closeDatabase() {
        sqlite3_close(db)
    }

    func createApiModelTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS ApiModel (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data BLOB
        );
        """
        executeQuery(createTableQuery)
    }

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
    func insertApiModel(_ model: ApiModel) {
        let insertQuery = "INSERT OR REPLACE INTO ApiModel (data) VALUES (?);"
        var statement: OpaquePointer?

        // Encode `ApiModel` to JSON `Data`
        do {
            let jsonData = try JSONEncoder().encode(model)

            if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
                // Bind the JSON data
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
    func fetchApiModel() -> ApiModel? {
        let query = "SELECT data FROM ApiModel LIMIT 1;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                if let dataPointer = sqlite3_column_blob(statement, 0) {
                    let dataSize = Int(sqlite3_column_bytes(statement, 0))
                    let data = Data(bytes: dataPointer, count: dataSize)
                    
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

