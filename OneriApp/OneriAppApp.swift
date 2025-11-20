//
//  OneriAppApp.swift
//  OneriApp
//
//  Created by selinay ceylan on 11.10.2025.
//

import SwiftUI
import FirebaseCore

@main
struct OneriAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        NavigationBarStyle.setupNavigationBar()
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
