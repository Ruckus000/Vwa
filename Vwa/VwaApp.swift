//
//  VwaApp.swift
//  Vwa
//
//  Created by J Philistin on 1/31/26.
//

import SwiftUI

@main
struct VwaApp: App {
    @StateObject private var store = TermStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(store)
                .preferredColorScheme(store.theme == .dark ? .dark : .light)
        }
    }
}
