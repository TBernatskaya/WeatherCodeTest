//
//  WeatherView.swift
//  CodeTest
//
//  Created by Tatiana Bernatskaya on 2021-01-20.
//  Copyright © 2021 Emmanuel Garnier. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Button("Add location", action: { viewModel.add(location: WeatherLocation.randomElement()) })

            List(viewModel.entries, id: \.id) { entry in
                LocationRow(entry: entry)
                    .onTapGesture(perform: {
                        viewModel.remove(location: entry)
                    })
            }
            .onAppear(perform: {
                viewModel.refresh()
            })
        }
    }
}

struct LocationRow: View {
    var entry: WeatherLocation

    var body: some View {
        HStack {
            Text(entry.name)
            Spacer()
            Text(entry.status.emoji)
            Spacer()
            Text("\(entry.temperature)ºC")
        }
        .foregroundColor(entry.status.backgroundColor)
    }
}

private extension WeatherLocation.Status {
    var emoji: String {
        switch self {
        case .cloudy: return "☁️"
        case .sunny: return "☀️"
        case .mostlySunny: return "🌤"
        case .partlySunny: return "🌤"
        case .partlySunnyRain: return "🌦"
        case .thunderCloudAndRain: return "⛈"
        case .tornado: return "🌪"
        case .barelySunny: return "🌥"
        case .lightening: return "🌩"
        case .snowCloud: return "🌨"
        case .rainy: return "🌧"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .cloudy, .rainy, .snowCloud: return .gray
        case .tornado, .thunderCloudAndRain, .lightening: return Color(red: 255 / 255, green: 113 / 255, blue: 113 / 255)
        case .sunny, .mostlySunny, .partlySunny, .barelySunny, .partlySunnyRain: return Color(red: 114 / 255, green: 168 / 255, blue: 255 / 255)
        }
    }
}

extension WeatherLocation {
    static func randomElement() -> WeatherLocation {
        let cities = ["New York", "Hong Kong", "Kiev", "Moscow", "Helsinki", "Tallin", "Madrid", "Tokyo", "Kyoto"]

        return WeatherLocation(id: UUID().uuidString,
                               name: cities.randomElement()!,
                               status: WeatherLocation.Status.allCases.randomElement()!,
                               temperature: Int.random(in: -20..<40))
    }
}
