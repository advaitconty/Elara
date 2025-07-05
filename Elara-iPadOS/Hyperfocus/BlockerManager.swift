//
//  BlockerManager.swift
//  Elara
//
//  Created by Milind Contractor on 5/7/25.
//

import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import Combine

class HyperfocusModel: ObservableObject {
    static let shared = HyperfocusModel()
    
    @Published var isRunning: Bool = false
    @Published var selectionToDiscourage: FamilyActivitySelection = FamilyActivitySelection()
    
    private let store = ManagedSettingsStore()
    
    func startDeviceActivityMonitoring(blocking selection: FamilyActivitySelection, until endDate: Date) {
        selectionToDiscourage = selection
        let now = Date()
        let calendar = Calendar.current
        
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: endDate)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )
        
        let activity = DeviceActivityName("Hyperfocus")
        
        do {
            try DeviceActivityCenter().startMonitoring(activity, during: schedule)
            isRunning = true
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }
    
    func stopDeviceActivityMonitoring() {
        let activity = DeviceActivityName("Hyperfocus")
        DeviceActivityCenter().stopMonitoring([activity])
        
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        isRunning = false
    }
    
    func applyImmediateShield(blocking selection: FamilyActivitySelection) {
        selectionToDiscourage = selection
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
    }
    
    func removeImmediateShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
}
