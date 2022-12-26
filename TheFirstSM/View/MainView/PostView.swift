//
//  PostView.swift
//  TheFirstSM
//
//  Created by Benji Loya on 26/12/2022.
//

import SwiftUI

struct PostView: View {
    @State private var createNewPost: Bool = false
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .hAlign(.center).vAlign(.center)
            .overlay(alignment: .bottomTrailing){
        Button {
            createNewPost.toggle()
        } label: {
            Image(systemName: "plus")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(14)
                .background(.black,in: Circle())
        }
        .padding(15)
            }
            .fullScreenCover(isPresented: $createNewPost){
                CreateNewPost { post in
                    
                }
            }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
