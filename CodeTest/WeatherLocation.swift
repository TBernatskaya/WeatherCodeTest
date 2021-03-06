//
//  Copyright © Webbhälsa AB. All rights reserved.
//

struct WeatherLocation: Codable {
    enum Status: String, Codable, CaseIterable {
        case cloudy = "CLOUDY"
        case sunny = "SUNNY"
        case mostlySunny = "MOSTLY_SUNNY"
        case partlySunny = "PARTLY_SUNNY"
        case partlySunnyRain = "PARTLY_SUNNY_RAIN"
        case thunderCloudAndRain = "THUNDER_CLOUD_AND_RAIN"
        case tornado = "TORNADO"
        case barelySunny = "BARELY_SUNNY"
        case lightening = "LIGHTENING"
        case snowCloud = "SNOW_CLOUD"
        case rainy = "RAINY"
    }
    let id: String
    let name: String
    let status: Status
    let temperature: Int
}

struct LocationsResult: Decodable {
    var locations: [WeatherLocation]
}
