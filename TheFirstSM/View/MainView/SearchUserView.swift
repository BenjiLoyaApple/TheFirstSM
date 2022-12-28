//
//  SearchUserView.swift
//  TheFirstSM
//
//  Created by Benji Loya on 28/12/2022.
//

import SwiftUI
import FirebaseFirestore

struct SearchUserView: View {
    /// - View Properties
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
//        NavigationStack{
            List{
                ForEach(fetchedUsers){user in
                    NavigationLink {
                        ReusableProfileContent(user: user)
                    }label: {
                        Text(user.username)
                            .font(.callout)
                            .hAlign(.leading)
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Search Users")
            .searchable(text: $searchText)
            .onSubmit(of: .search, {
                /// - Fetch User From Firebase
                Task{await searchUsers()}
            })
            .onChange(of: searchText, perform: { newValue in
                if newValue.isEmpty{
                    fetchedUsers = []
                }
            })
            
//            .toolbar{
//                ToolbarItem(placement: .navigationBarTrailing){
//                    Button("Cancel"){
//                        dismiss()
//                    }
//                    .tint(.black)
//                }
//            }
        
    }
    func searchUsers()async{
        do{
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("username", isGreaterThanOrEqualTo: searchText)
                .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }
            /// - UI Must Be Updated on Main Thread
            await MainActor.run(body: {
                fetchedUsers = users
            })
        }catch{
            print(error.localizedDescription)
        }
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
