//
//  TheFirstSMApp.swift
//  TheFirstSM
//
//  Created by Benji Loya on 12/12/2022.
//

import SwiftUI
import Firebase

@main
struct TheFirstSMApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
