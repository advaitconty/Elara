//
//  live_activitiesLiveActivity.swift
//  live-activities
//
//  Created by Milind Contractor on 2/6/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct live_activitiesAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: String
        var remainingMinutes: String
        var workStatus: String
        var isRunning: Bool
        var startTime: [Int]
        
        var timeDone: Float {
            return Float((Int(remainingMinutes) ?? 0) * 60 + (Int(remainingSeconds) ?? 0))
        }
        var total: Float {
            return Float(Int(startTime[0]) * 60 + Int(startTime[1]))
        }
    }
    
    var name: String
}

struct live_activitiesLiveActivity: Widget {
    @State var size: CGSize = .zero
    @Environment(\.colorScheme) var colorScheme
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: live_activitiesAttributes.self) { context in
//            ZStack {
//                Color.black
//                
//                VStack {
//                    HStack {
//                        VStack {
//                            HStack {
//                                Text("\(context.state.remainingMinutes):\(context.state.remainingSeconds)")
//                                    .font(.system(size: 36, weight: .bold, design: .serif))
//                                    .foregroundStyle(.white)
//                                Spacer()
//                            }
//                            HStack {
//                                Text(context.state.workStatus)
//                                    .font(.system(size: 24, weight: .light, design: .serif))
//                                    .italic()
//                                    .foregroundStyle(.white)
//                                Spacer()
//                            }
//                        }
//                        Spacer()
//                        Button {
//                            
//                        } label: {
//                            Image(systemName: context.state.isRunning ? "pause.circle": "play.circle")
//                                .font(.system(size: 48))
//                        }
//                        .buttonStyle(.borderless)
//                        .foregroundStyle(.white)
//                    }
//                    .padding()
//                    
//                    ProgressView(value: context.state.timeDone, total: context.state.total)
//                        .tint(.accent)
//                    
//                    GeometryReader { proxy in
//                        HStack {} // just an empty container to triggers the onAppear
//                            .onAppear {
//                                size = proxy.size
//                                print(size)
//                            }
//                    }
//                }
//            }
            VStack {
                Text("Test")
            }
                .activityBackgroundTint(Color.accent)
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Top")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension live_activitiesAttributes {
    fileprivate static var preview: live_activitiesAttributes {
        live_activitiesAttributes(name: "World")
    }
}

extension live_activitiesAttributes.ContentState {
    fileprivate static var work: live_activitiesAttributes.ContentState {
        live_activitiesAttributes.ContentState(remainingSeconds: "00", remainingMinutes: "23", workStatus: "Work", isRunning: false, startTime: [25, 0])
    }
    
    fileprivate static var shortBreak: live_activitiesAttributes.ContentState {
        live_activitiesAttributes.ContentState(remainingSeconds: "00", remainingMinutes: "3", workStatus: "Short Break", isRunning: true, startTime: [5, 0])
    }
    
    fileprivate static var longBreak: live_activitiesAttributes.ContentState {
        live_activitiesAttributes.ContentState(remainingSeconds: "00", remainingMinutes: "7", workStatus: "Long Break", isRunning: false, startTime: [10, 0])
    }
}

