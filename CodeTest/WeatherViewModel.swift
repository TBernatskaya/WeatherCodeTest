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
                self.entries = list.locations
                completion(true, nil)
            case .failure(let error): self.handle(error: error, completion: completion)
            }
        })
    }

    func add(location: WeatherLocation, completion: @escaping (Bool, String?) -> ()) {
        service.add(location: location,
                    completion: { result in
                        switch result {
                        case .success(_): self.refresh(completion: completion)
                        case .failure(let error): self.handle(error: error, completion: completion)
                        }
                    })
    }

    func remove(index: Int, completion: @escaping (Bool, String?) -> ()) {
        guard index >= 0,
              entries.count > index
        else { return completion(false, ServiceError.cannotRemoveLocation.text) }

        let location = entries[index]
        service.remove(locationID: location.id,
                       completion: { result in
                            switch result {
                            case .success(_): self.refresh(completion: completion)
                            case .failure(let error): self.handle(error: error, completion: completion)
                            }
                       })
    }

    fileprivate func handle(error: Error, completion: @escaping (Bool, String?) -> ()) {
        let serviceError = error as? ServiceError
        completion(false, serviceError?.text ?? error.localizedDescription)
    }
}

extension ServiceError {
    var text: String {
        switch self {
        case .generic: return "List update failed"
        case .cannotAddLocation: return "Failed to add location"
        case .cannotRemoveLocation: return "Failed to remove location"
        }
    }
}
