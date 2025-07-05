import WidgetKit
import SwiftUI

let quotes = ["hlelo"]

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Inspirations {
        Inspirations(date: Date(), quote: motivationalQuotes[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (Inspirations) -> ()) {
        let entry = Inspirations(date: Date(), quote: motivationalQuotes.randomElement()!)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Inspirations>) -> ()) {
        var entries: [Inspirations] = []
        let currentDate = Date()

        for minuteOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 30, to: currentDate)!
            let randomQuote = motivationalQuotes.randomElement()!
            let entry = Inspirations(date: entryDate, quote: randomQuote)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct Inspirations: TimelineEntry {
    let date: Date
    let quote: Quote
}

struct InspirationsWidgetView: View {
    var entry: Inspirations
    
    var body: some View {
        VStack {
            Text(entry.quote.quote)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
            HStack {
                Spacer()
                Text("- \(entry.quote.author)")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
            }
        }
    }
}

struct InspirationsWidget: Widget {
    let kind: String = "ElaraInspirations"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                InspirationsWidgetView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color.accentColor
                    }
            } else {
                InspirationsWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Elara Inspirations")
        .description("A quick and easy way to hop back into Elara with some inspiration to get you productive.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    InspirationsWidget()
} timeline: {
    Inspirations(date: Date(), quote: Quote(quote: "I've learned that people will forget what you said, people will forget what you did, but people will never forget how you made them feel.", author: "Maya Angelou"))
    Inspirations(date: Date(), quote: Quote(quote: "Dream it. Wish it. Do it.", author: "Anonymous"))
}
