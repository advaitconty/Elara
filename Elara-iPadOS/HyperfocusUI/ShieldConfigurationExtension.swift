//
//  ShieldConfigurationExtension.swift
//  HyperfocusUI
//
//  Created by Milind Contractor on 5/7/25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.118, green: 0.295, blue: 0.487, alpha: 1),
            icon: UIImage(systemName: "nosign.app"),
            title: ShieldConfiguration.Label(
                text: "🚫 Elara Hyperfocus has blocked this app",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Hyperfocus is running and has blocked \(application.localizedDisplayName ?? "this app")! Please stay focused!",
                color: .white
            )
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThinMaterial,
            backgroundColor: UIColor(red: 0.118, green: 0.295, blue: 0.487, alpha: 1),
            icon: UIImage(systemName: "nosign.app"),
            title: ShieldConfiguration.Label(
                text: "🚫 Elara Hyperfocus has blocked this app",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Hyperfocus is running and has blocked \(application.localizedDisplayName ?? "this app")! Please stay focused!",
                color: .white
            )
        )
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThinMaterial,
            backgroundColor: UIColor(red: 0.118, green: 0.295, blue: 0.487, alpha: 1),
            icon: UIImage(systemName: "network.badge.shield.half.filled"),
            title: ShieldConfiguration.Label(
                text: "🚫 Elara Hyperfocus has blocked this app",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Hyperfocus is running and has blocked \(webDomain.domain ?? "this app")! Please stay focused!",
                color: .white
            )
        )
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThinMaterial,
            backgroundColor: UIColor(red: 0.118, green: 0.295, blue: 0.487, alpha: 1),
            icon: UIImage(systemName: "network.badge.shield.half.filled"),
            title: ShieldConfiguration.Label(
                text: "🚫 Elara Hyperfocus has blocked this app",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Hyperfocus is running and has blocked \(webDomain.domain ?? "this app")! Please stay focused!",
                color: .white
            )
        )
    }
}
