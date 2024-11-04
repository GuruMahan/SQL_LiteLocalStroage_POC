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
    
    func loadData() async {
        guard let url = URL(string: link) else{print("Invalid URL")
            return
        }
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ApiModel.self, from: data){
                DispatchQueue.main.async {
                   // print("jsonvalue====>", self.jsonvalue)
                   // self.storeSQLiteData(apiModel: decodedResponse)
                    self.fetchSQLiteData()
                }
            }
        }catch let error {
            print("error=========>Invalid data", error)
            self.fetchSQLiteData()
        }
    }
    
    let dbHelper = SQDBHelper.shared

    func storeSQLiteData(apiModel: ApiModel) {
        dbHelper.insertApiModel(apiModel)
    }
    
    func fetchSQLiteData() {
        if let retrievedApiModel = dbHelper.fetchApiModel() {
            self.dataList = retrievedApiModel
            self.jsonvalue = retrievedApiModel.data
            print("Retrieved ApiModel:", retrievedApiModel)
        }
    }
}
