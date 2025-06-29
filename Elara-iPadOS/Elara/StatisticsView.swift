//
//  StatisticsView.swift
//  Elara
//
//  Created by Milind Contractor on 21/6/25.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @Binding var settingsData: SettingData
    @Binding var statisticsData: [Cycle]
    @State var sortedDataByTasks: [SortedDataByTasks] = []
    @State var sortedDataByDate: [SortedDataByDate] = []
    @State var loadingData: Bool = true
    @State var maxGraphLength: Int = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 52))
                VStack {
                    HStack {
                        Text("Elara Vista")
                            .font(.custom(settingsData.font.titleFont, size: 36))
                            .italic()
                        Spacer()
                    }
                    HStack {
                        Text("Your productivity made visible")
                            .font(.custom(settingsData.font.bodyFont, size: 14))
                        Spacer()
                    }
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
                .tint(.gray)
                .hoverEffect()
            }
            .padding()
            
            if loadingData {
                ProgressView()
                Text("Crunching the numbers")
                    .font(.custom(settingsData.font.bodyFont, size: 18))
                    .onAppear {
                        for statisticItem in statisticsData {
                            if !sortedDataByTasks.contains(where: { $0.task == statisticItem.workingOnTask.task}) {
                                sortedDataByTasks.append(SortedDataByTasks(task: statisticItem.workingOnTask.task, timeSpentOnTask: statisticItem.timeSpentOnWorkCycle))
                            } else {
                                sortedDataByTasks[sortedDataByTasks.firstIndex(where: { $0.task == statisticItem.workingOnTask.task} )!].timeSpentOnTask += statisticItem.timeSpentOnWorkCycle
                            }
                        }
                        
                        for sortedDataByTask in sortedDataByTasks {
                            if (sortedDataByTask.timeSpentOnTask / 60) > maxGraphLength {
                                maxGraphLength = sortedDataByTask.timeSpentOnTask / 60
                            }
                        }
                        
                        maxGraphLength += 25
                        
                        loadingData = false
                        
                        
                        
                    }
            } else {
                VStack(spacing: 50) {
                    if !sortedDataByTasks.isEmpty {
                        Text("Time spent based on tasks")
                            .font(.custom(settingsData.font.titleFont, size: 24))
                        Chart {
                            ForEach(sortedDataByTasks) { item in
                                BarMark(
                                    x: .value("Task", item.task),
                                    y: .value("Total Time Spent", item.timeSpentOnTask / 60)
                                )
                                .annotation(position: .bottom) {
                                    Text(item.task)
                                        .font(.custom(settingsData.font.bodyFont, size: 12))
                                }
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYScale(domain: 0...maxGraphLength)
                        .frame(maxWidth: 400, maxHeight: 400)
                        .tint(.accent)
                    } else {
                        VStack {
                            Text("No data has been collected yet! Check back after finishing some cycles and tasks!")
                                .font(.custom(settingsData.font.bodyFont, size: 18))
                            Text("P.S.: Only data collected after you updated to Elara v2.0 will be collected")
                                .font(.custom(settingsData.font.bodyFont, size: 18))
                                .italic()
                        }
                    }
                    
                    //                    if !sortedDataByDate.isEmpty {
                    //                        Text("Time spent based on tasks")
                    //                            .font(.custom(settingsData.font.titleFont, size: 24))
                    //                        Chart {
                    //                            ForEach(sortedDataByDate) { item in
                    //                                BarMark(
                    //                                    x: .value("Date", item.displayFriendlyDate),
                    //                                    y: .value("Total Time Spent", item.timeSpentOnTask / 60)
                    //                                )
                    //                                .annotation(position: .bottom) {
                    //                                    Text(item.displayFriendlyDate)
                    //                                        .font(.custom(settingsData.font.bodyFont, size: 12))
                    //                                }
                    //                            }
                    //                        }
                    //                        .chartXAxis(.hidden)
                    //                        .chartYScale(domain: 0...maxGraphLength)
                    //                        .frame(maxWidth: 400, maxHeight: 400)
                    //                        .tint(.accent)
                }
            }
        }
        .padding()
    }
}

#Preview {
    StatisticsView(settingsData: .constant(SettingData()),statisticsData: .constant([Cycle(timeSpentOnWorkCycle: 1500, timeSpentOnBreakCycle: 300, workingOnTask: Todo(task: "Finish Elara", priority: 1)), Cycle(timeSpentOnWorkCycle: 1500, timeSpentOnBreakCycle: 300, workingOnTask: Todo(task: "Finish Elara", priority: 1)), Cycle(timeSpentOnWorkCycle: 1500, timeSpentOnBreakCycle: 300, workingOnTask: Todo(task: "Finish Elara v2", priority: 1))]))
}
