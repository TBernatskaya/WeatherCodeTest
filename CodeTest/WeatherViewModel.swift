//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import Foundation

class WeatherViewModel {
    public private(set) var entries: [WeatherLocation] = []
    private let service: WeatherService

    init(service: WeatherService) {
        self.service = service
    }

    func refresh(completion: @escaping (Bool, String?) -> ()) {
        service.fetchLocations(completion: { result in
            switch result {
            case .success(let list):
                self.entries = list
                completion(true, nil)
            case .failure(let error): completion(false, error.localizedDescription)
            }
        })
    }

    func add(location: WeatherLocation, completion: @escaping (Bool, String?) -> ()) {
        service.add(location: location,
                    completion: { result in
                        switch result {
                        case .success(): self.refresh(completion: completion)
                        case .failure(let error): completion(false, error.localizedDescription)
                        }
                    })
    }
}
