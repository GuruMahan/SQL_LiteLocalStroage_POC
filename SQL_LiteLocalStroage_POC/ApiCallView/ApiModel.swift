//
//  ApiModel.swift
//  ApiCalledSUI
//
//  Created by Guru Mahan on 30/12/22.
//

import Foundation

struct ApiModel: Codable {
    let data: [innerData]
}

// MARK: - innerData
struct innerData: Codable {
    let idNation:String
    let nation: String
    let idYear: Int
    let year: String
    let population: Int
    let slugNation: String
    
    enum CodingKeys: String, CodingKey {
        case idNation = "ID Nation"
        case nation = "Nation"
        case idYear = "ID Year"
        case year = "Year"
        case population = "Population"
        case slugNation = "Slug Nation"
    }
}

// MARK: - Source
struct Source: Codable {
    let measures: [String]
    let annotations: Annotations
    let name: String
}

// MARK: - Annotations
struct Annotations: Codable {
    let sourceName, sourceDescription, datasetName: String
    let datasetLink: String
    let tableID, topic, subtopic: String
    
    enum CodingKeys: String, CodingKey {
        case sourceName = "source_name"
        case sourceDescription = "source_description"
        case datasetName = "dataset_name"
        case datasetLink = "dataset_link"
        case tableID = "table_id"
        case topic, subtopic
    }
}
