//
//  ApiDetailsView.swift
//  ApiCalledSUI
//
//  Created by Guru Mahan on 30/12/22.
//

import SwiftUI

struct ApiDetailsView: View {
    
    @ObservedObject var viewModel = ApiViewModel()
    let model: innerData?
    var population1 : ApiModel?
    
    var body: some View {
        ZStack{
            VStack{
                Text("\(model?.population ?? 0)")
                Text(model?.idNation ?? "")
                Text(model?.nation ?? "")
            }
        }
    }
}

struct ApiDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ApiDetailsView(model: nil)
    }
}
