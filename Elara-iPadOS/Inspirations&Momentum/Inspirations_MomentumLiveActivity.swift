//
//  Inspirations_MomentumLiveActivity.swift
//  Inspirations&Momentum
//
//  Created by Milind Contractor on 4/7/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Inspirations_MomentumAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Inspirations_MomentumLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Inspirations_MomentumAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Inspirations_MomentumAttributes {
    fileprivate static var preview: Inspirations_MomentumAttributes {
        Inspirations_MomentumAttributes(name: "World")
    }
}

extension Inspirations_MomentumAttributes.ContentState {
    fileprivate static var smiley: Inspirations_MomentumAttributes.ContentState {
        Inspirations_MomentumAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Inspirations_MomentumAttributes.ContentState {
         Inspirations_MomentumAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Inspirations_MomentumAttributes.preview) {
   Inspirations_MomentumLiveActivity()
} contentStates: {
    Inspirations_MomentumAttributes.ContentState.smiley
    Inspirations_MomentumAttributes.ContentState.starEyes
}
