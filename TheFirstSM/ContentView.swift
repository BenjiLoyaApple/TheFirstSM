//
//  ContentView.swift
//  TheFirstSM
//
//  Created by Benji Loya on 12/12/2022.
//



import SwiftUI

struct ContentView: View {
    @AppStorage("logo_status") var logStatus: Bool = false
    var body: some View {
//        MARK: Redirecting User Based on Log Status
        if logStatus {
            Text("Main View")
        }else{
            LoginView()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
