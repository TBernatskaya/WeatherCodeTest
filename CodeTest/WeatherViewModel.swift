//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published public private(set) var entries: [WeatherLocation] = []
    private let service: WeatherService
    private var cancellable : Set<AnyCancellable> = Set()

    init(service: WeatherService) {
        self.service = service
    }

    func refresh() {
        service.fetchLocations()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { values in
                    self.entries = values.locations
                  }
            )
            .store(in: &cancellable)
    }

    func add(location: WeatherLocation) {
        service.add(location: location)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { _ in self.refresh() }
            )
            .store(in: &cancellable)
    }

    func remove(location: WeatherLocation) {
        service.remove(locationID: location.id)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { _ in self.refresh() }
            )
            .store(in: &cancellable)
    }

    // TODO: Use this error handling
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
