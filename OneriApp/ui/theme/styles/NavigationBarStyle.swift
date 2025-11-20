//
//  NavigationBarStyle.swift
//  OneriApp
//
//  Created by selinay ceylan on 11.10.2025.
//

import Foundation
import SwiftUI

class NavigationBarStyle {
    static func setupNavigationBar() {
        let largeAppearance = UINavigationBarAppearance()
        largeAppearance.backgroundColor = UIColor(AppColor.mainColor)
        largeAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        largeAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        let inlineAppearance = UINavigationBarAppearance()
        inlineAppearance.backgroundColor = UIColor(AppColor.mainColor)
        inlineAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        UINavigationBar.appearance().standardAppearance = inlineAppearance
        UINavigationBar.appearance().compactAppearance = inlineAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = largeAppearance
        UINavigationBar.appearance().tintColor = .white
    }
}
