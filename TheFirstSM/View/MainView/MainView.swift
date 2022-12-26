//
//  MainView.swift
//  TheFirstSM
//
//  Created by Benji Loya on 15/12/2022.
//

import SwiftUI

struct MainView: View {
    var body: some View {
//        MARK: TabView with recent post's and profile tabs
        
        TabView{
            PostView()
                .tabItem{
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                }
            ProfileView()
                .tabItem{
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
//        Canging Tab Lable Tint To Black
        .tint(.black)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
