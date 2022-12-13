//
//  LoginView.swift
//  TheFirstSM
//
//  Created by Benji Loya on 12/12/2022.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage


struct LoginView: View {
    
//    MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    
//     MARK: View Properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
//    MARK: User Defaults
    @AppStorage("logo_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome back,\nYou have been missed")
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing: 12) {
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                SecureField("Password", text: $password)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button(action: loginUser) {
//                    MARK: Login Button
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 10)
            }
            
//   MARK: Register Button
            
            HStack {
                Text("Don't have an account")
                    .foregroundColor(.gray)
                
                Button("Register Now") {
                    createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        
        
//        MARK: Register View VIA Sheets
        .fullScreenCover(isPresented: $createAccount) {
            RegisterView()
        }
//        MARK: Displaying alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    func loginUser(){
        isLoading = true
        Task {
            do{
//                With the help of swift concurrency Auth can be done with single line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("user found")
                try await fectchUser()
            }catch{
                await setError(error)
            }
        }
    }
    
//    MARK: if user if found then fetching user data from firestore
    func fectchUser()async throws{
        guard let userID = Auth.auth().currentUser?.uid else{return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
//        MARK: UI updating must be run mainthread
        await MainActor.run(body: {
//            Setting userDefaults data and changing app's auth status
            userUID = userID
            userNameStored = user.username
            profileURL = user.userProfileURL
            logStatus = true
        })
    }
    
    func resetPassword(){
        Task {
            do{
//                With the help of swift concurrency Auth can be done with single line
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("link sent")
            }catch{
                await setError(error)
            }
        }
    }
    
//        MARK: Displaying Error VIA Alert
    func setError(_ error: Error)async{
//        MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

//   MARK: Register View

struct RegisterView: View {
    
//    MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    
//    MARK: View Propertiies
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
//    MARK: User Defaults
    @AppStorage("logo_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Register\nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Hello user, have a wonderful journey")
                .font(.title3)
                .hAlign(.leading)
        
//            MARK: For Smaller Size Optimization
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                
                HelperView()
                
            }
       
//   MARK: Register Button
            
            HStack {
                Text("Already have an account")
                    .foregroundColor(.gray)
                
                Button("Login Now") {
                   dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
//            MARK: Extracting UIImage From Photoitem
            if let newValue{
                Task{
                    do{
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else{return}
//                        MARK: UI Must Be Updated on Main Thread
                        await MainActor.run(body: {
                            userProfilePicData = imageData
                        })
                    }catch{}
                }
            }
        }
        
//         MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
        
    }
    
    @ViewBuilder
    func HelperView()->some View {
        VStack(spacing: 12) {
            ZStack {
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }else{
                    Image("nullProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 25)
            
            TextField("Username", text: $userName)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
                
            
            TextField("Email", text: $emailID)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            SecureField("Password", text: $password)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio Link (Optional)", text: $userBioLink)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            Button(action: registerUser){
//                    MARK: Login Button
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }
            .disableWithOpacity(userName == "" || userBio == "" || emailID == "" || password == "" || userProfilePicData == nil)
            .padding(.top, 10)
        }
    }
    
    func registerUser(){
        isLoading = true
        Task{
            do{
//                step 1: Creating Firebase Account
                try await Auth.auth().createUser(withEmail: emailID, password: password)
//                step 2: Updating profile photo into firebase storage
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                guard let imageData = userProfilePicData else{return}
                let storageRef = Storage.storage().reference().child("Profile_Image").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
//                step 3: Downloading photo URl
                let downloadURL = try await storageRef.downloadURL()
//                step 4: Creating a user Firestore Object
                let user = User(username: userName, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: emailID, userProfileURL: downloadURL)
//                step 5: Saving user Doc into Firestore Database
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: {
                    error in
                    if error == nil {
//                        MARK: Print Saved SuccessFully
                        print("Saved SuccessFully")
                        userNameStored = userName
                        self.userUID = userUID
                        profileURL = downloadURL
                        logStatus = true
                    }
                })
            }catch{
//                MARK: Deleting creating account in case of failure
                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
        }
    }
    //     MARK: Displaying Error VIA Alert
    func setError(_ error: Error)async{
        //     MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
//        RegisterView()
    }
}

//   MARK: View Extension For UI Building

extension View {
//     MARK: Disabling with Opacity
    func disableWithOpacity(_ condition: Bool)->some View{
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
    
    func hAlign(_ aligment: Alignment)->some View {
        self
            .frame(maxWidth: .infinity, alignment: aligment)
    }
    func vAlign(_ aligment: Alignment)->some View {
        self
            .frame(maxHeight: .infinity, alignment: aligment)
    }
    
//    MARK: Custom Border View With Padding
    func border(_ width: CGFloat,_ color: Color)->some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
//    MARK: Custom Fill View With Padding
    func fillView(_ color: Color)->some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
}
