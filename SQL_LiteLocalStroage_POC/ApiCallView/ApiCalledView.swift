//
//  ContentView.swift
//  ApiCalledSUI
//
//  Created by Guru Mahan on 30/12/22.
//

import SwiftUI

struct ApiCalledView: View {
    
    @ObservedObject var viewModel = ApiViewModel()
    @State var result = [innerData]()
    @State var nextPage = false
    
    var body: some View {
        NavigationStack{
            ScrollView{
                ZStack{
                    LinearGradient(colors: [Color.green.opacity(0.2)], startPoint:.trailing, endPoint: .leading)
                    VStack {
                        Image(systemName:"book")
                            .fontWeight(.bold)
                            .frame(height: 100)
                        Spacer()
                        VStack{
                            ForEach(0..<(viewModel.dataList?.data.count ?? 0), id:\.self) { result in
                                apiListView(list: viewModel.jsonvalue[result])
                            }
                        }
                    }
                }
                .cornerRadius(10)
            }
            .navigationDestination(isPresented: $nextPage){
                ApiDetailsView(model: viewModel.isSelected)
                    .navigationBarTitleDisplayMode(.automatic)
                    .navigationBarBackButtonHidden(false)
            }
            .task{
                await viewModel.loadData()
            }
        }
    }
    
    @ViewBuilder func apiListView(list: innerData?) -> some View{
        ZStack {
            HStack() {
                VStack(alignment:.leading){
                    HStack{
                        Text("Population:\(list?.population ?? 0)")
                            .fontWeight(.bold)
                            .padding(.leading)
                        Spacer()
                        Button{
                            viewModel.isSelected = list
                            nextPage = true
                        } label: {
                            Image(systemName: "chevron.forward.2")
                                .foregroundColor(.black)
                                .padding()
                        }
                    }
                    Text("NationID:\(list?.idNation ?? "") ")
                        .font(Font.subheadline)
                        .foregroundColor(.red)
                        .padding(.leading)
                    Text("Nation:\(list?.nation ?? "") ")
                        .font(Font.subheadline)
                        .padding(.leading)
                    Text("Year:\(list?.year ?? "") ")
                        .font(Font.subheadline)
                        .padding(.leading)
                    Text("IDYear:\(list?.idYear ?? 0) ")
                        .font(Font.subheadline)
                        .foregroundColor(.brown)
                        .padding(.leading)
                    Divider()
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ApiCalledView()
    }
}
