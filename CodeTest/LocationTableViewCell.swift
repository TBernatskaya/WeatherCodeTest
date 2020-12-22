//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    static var reuseIdentifier: String {
        return "cellReuseIdentifier"
    }

    func setup(_ entry: WeatherLocation) {
        cityNameLabel.text = entry.name
        statusLabel.text = entry.status.emoji
        temperatureLabel.text = "\(entry.temperature)ºC"
        cardView.backgroundColor = entry.status.backgroundColor
    }
}

private extension WeatherLocation.Status {
    var emoji: String {
        switch self {
        case .cloudy: return "☁️"
        case .sunny: return "☀️"
        case .mostlySunny: return "🌤"
        case .partlySunnyRain: return "🌦"
        case .thunderCloudAndRain: return "⛈"
        case .tornado: return "🌪"
        case .barelySunny: return "🌥"
        case .lightening: return "🌩"
        case .snowCloud: return "🌨"
        case .rainy: return "🌧"
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .cloudy, .rainy, .snowCloud: return .lightGray
        case .tornado, .thunderCloudAndRain, .lightening: return UIColor(red: 255 / 255, green: 113 / 255, blue: 113 / 255, alpha: 1)
        case .sunny, .mostlySunny, .barelySunny, .partlySunnyRain: return UIColor(red: 114 / 255, green: 168 / 255, blue: 255 / 255, alpha: 1)
        }
    }
}
