//
//  AppleHealthView.swift
//  iOS-Examples-W6
//
//  Created by Oleksandr Yeroshkin on 17/11/2025.
//

import SwiftUI
import Charts

struct StepData: Identifiable {
    let id = UUID()
    let hour: Int
    let steps: Int
}

struct AppleHealthView: View {
    @State private var selectedTimeRange: TimeRange = .day
    @State private var selectedTab: TabItem = .summary
    
    // MARK: - Sample enums
    enum TimeRange: String, CaseIterable {
        case day = "D"
        case week = "W"
        case month = "M"
        case sixMonths = "6M"
        case year = "Y"
    }
    
    enum TabItem: String, CaseIterable {
        case summary = "Summary"
        case sharing = "Sharing"
        case browse = "Browse"
        
        var icon: String {
            switch self {
            case .summary: return "heart.fill"
            case .sharing: return "person.2.fill"
            case .browse: return "square.grid.2x2.fill"
            }
        }
    }
    
    // MARK: -  Sample step data for the chart (24 hours)
    let stepData: [StepData] = [
        StepData(hour: 0, steps: 0), StepData(hour: 1, steps: 0), StepData(hour: 2, steps: 0),
        StepData(hour: 3, steps: 0), StepData(hour: 4, steps: 0), StepData(hour: 5, steps: 0),
        StepData(hour: 6, steps: 120), StepData(hour: 7, steps: 350), StepData(hour: 8, steps: 280),
        StepData(hour: 9, steps: 1000), StepData(hour: 10, steps: 320), StepData(hour: 11, steps: 180),
        StepData(hour: 12, steps: 420), StepData(hour: 13, steps: 380), StepData(hour: 14, steps: 290),
        StepData(hour: 15, steps: 340), StepData(hour: 16, steps: 260), StepData(hour: 17, steps: 190),
        StepData(hour: 18, steps: 150), StepData(hour: 19, steps: 80), StepData(hour: 20, steps: 60),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: -   Main content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: -   Date range selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // MARK: -   Total steps section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TOTAL")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("1,900")
                                .font(.system(size: 48, weight: .bold, design: .default))
                                .foregroundColor(.primary)
                            
                            Text("steps")
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Yesterday")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                        
                        // MARK: -   Bar chart
                        VStack(alignment: .leading, spacing: 8) {
                            Chart(stepData) { data in
                                BarMark(
                                    x: .value("Hour", data.hour),
                                    y: .value("Steps", data.steps)
                                )
                                .foregroundStyle(Color.orange)
                                .cornerRadius(2)
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: 6)) { value in
                                    AxisValueLabel {
                                        if let hour = value.as(Int.self) {
                                            Text(formatHour(hour))
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    AxisGridLine()
                                        .foregroundStyle(Color(.separator).opacity(0.3))
                                }
                            }
                            .chartXScale(domain: 0...23)
                            .chartYScale(domain: 0...1000)
                            .chartYAxis {
                                AxisMarks(position: .trailing, values: [0, 500, 1000]) { value in
                                    AxisValueLabel {
                                        if let steps = value.as(Int.self) {
                                            Text("\(steps)")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    AxisGridLine()
                                        .foregroundStyle(Color(.separator).opacity(0.3))
                                }
                            }
                            .frame(height: 200)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        
                        // MARK: -   About Steps section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About Steps")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Step count is the number of steps you take throughout the day. Pedometers and digital activity trackers can help you determine your step count. These devices count steps for any activity that involves step-like movement, including walking, running, stair-climbing, cross-country skiing, and even movement as you go about your daily activities.")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(2)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                
                // MARK: -   Bottom navigation bar
                HStack(spacing: 0) {
                    ForEach(TabItem.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 20, weight: .regular))
                                
                                Text(tab.rawValue)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(selectedTab == tab ? .blue : .gray)
                        }
                    }
                }
                .frame(height: 60)
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(.separator)),
                    alignment: .top
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Steps")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Data") {
                        // Add data action
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 17, weight: .regular))
                }
            }
        }
    
    private func formatHour(_ hour: Int) -> String {
        switch hour {
        case 0: return "12 AM"
        case 6: return "6"
        case 12: return "12 PM"
        case 18: return "6"
        default: return ""
        }
    }
}

#Preview {
    AppleHealthView()
}
