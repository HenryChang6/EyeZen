//
//  IcapsApp.swift
//  Icaps
//
//  Created by 張百鴻 on 2024/7/1.
//

import SwiftUI

@main
struct IcapsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            Text("No main window")
        }
    }
}
