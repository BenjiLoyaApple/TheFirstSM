//
//  PostCardView.swift
//  TheFirstSM
//
//  Created by Benji Loya on 27/12/2022.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseStorage

struct PostCardView: View {
    var post: Post
    /// - Callbacks
    var onUpdate: (Post)->()
    var onDelete: ()->()
    /// - View Properties
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var docListner: ListenerRegistration?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6){
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                /// - Post Image if Any
                if let postImageURL = post.imageURL{
                    GeometryReader{
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .frame(height: 200)
                }
                PostInteraction()
            }
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing, content: {
            /// - Displaying Delete Button (if Author of that post)
            if post.userUID == userUID{
                Menu{
                    Button("Delete Post",role: .destructive,action: deletePost)
                }label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.accentColor)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        })
        .onAppear{
            /// - Adding Only Once
            if docListner == nil{
                guard let postID = post.id else{return}
                docListner = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists{
                            /// - Document Updeted
                            /// - Fetching Updated Document
                            if let updatedPost = try? snapshot.data(as: Post.self){
                                onUpdate(updatedPost)
                            }
                        }else{
                            /// - Document Deleted
                            onDelete()
                        }
                    }
                })
            }
        }
        .onDisappear{
//            MARK: Applying ShapShot listner Only when the post is available on the screen
//            Else removing the lister (it saves unwanted live updates from the posts whitch was swiped away from the screen)
            if let docListner{
                docListner.remove()
                self.docListner = nil
            }
        }
    }
    
//    MARK: Like/Dislike Interation
    @ViewBuilder
    func PostInteraction()->some View{
        HStack(spacing: 6){
            Button(action: likePost){
                Image(systemName: post.likedIDs.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: dislikePost) {
                Image(systemName: post.dislikedIDs.contains(userUID) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
            }
            .padding(.leading, 25)
            
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .foregroundColor(.accentColor)
        .padding(.vertical,8)
    }
    
    /// - Liking Post
    func likePost(){
        Task{
            guard let postID = post.id else{return}
            if post.likedIDs.contains(userUID){
                /// - Removing User ID From the Array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                  "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            }else{
                /// - Adding User ID to Liked Array and removing our ID from Disliked Array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID]),
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    /// - Dislike Post
    func dislikePost(){
        Task{
            guard let postID = post.id else{return}
            if post.dislikedIDs.contains(userUID){
                /// - Removing User ID From the Array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            }else{
                /// - Adding User ID to Liked Array and removing our ID from Disliked Array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayUnion([userUID]),
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    /// - Deleting Post
    func deletePost(){
        Task{
            /// - Step 1: Delete Image from Firebase Storage
            do{
                if post.imageReferenceID != "" {
                    try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                }
                    ///- Step 2: Delete Firestore Document
                    guard let postID = post.id else{return}
                    try await Firestore.firestore().collection("Posts").document(postID).delete()
            }catch{
                print(error.localizedDescription)
            }
            
        }
    }
}
