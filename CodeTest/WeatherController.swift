//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import Foundation

protocol WeatherView {
    func showEntries()
    func displayError()
}

class WeatherController {
    var view: WeatherView?

    public private(set) var entries: [WeatherLocation] = []

    init() {}

    internal func bind(view: WeatherView) {
        self.view = view
        refresh()
    }
}

extension WeatherController {
    func refresh() {
        var urlRequest = URLRequest(url: URL(string: "https://app-code-test.kry.pet/locations")!)
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        URLSession(configuration: .default).dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data else {
                    self.view?.displayError()
                    return
                }
                do {
                    let result = try JSONDecoder().decode(LocationsResult.self, from: data)
                    self.entries = result.locations
                    self.view?.showEntries()
                } catch {
                    self.view?.displayError()
                }
            }
        }.resume()
    }

    var apiKey: String {
        guard let apiKey = UserDefaults.standard.string(forKey: "API_KEY") else {
            let key = UUID().uuidString
            UserDefaults.standard.set(key, forKey: "API_KEY")
            return key
        }
        return apiKey
    }
}

private struct LocationsResult: Decodable {
    var locations: [WeatherLocation]
}
