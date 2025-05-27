//
//  AboutViewController.swift
//  Solstice
//
//  Created by Milind Contractor on 30/12/24.
//

import Foundation
import AppKit
import SwiftUI

class AboutWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "About Elara"
        window.contentView = NSHostingView(rootView: AboutView())
        self.init(window: window)
    }
}
