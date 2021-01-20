//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published public private(set) var entries: [WeatherLocation] = []
    @Published public var displayError: String?
    private let service: WeatherService
    private var cancellable : Set<AnyCancellable> = Set()

    init(service: WeatherService) {
        self.service = service
    }

    func refresh() {
        service.fetchLocations()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { self.handle(completion: $0) },
                receiveValue: { self.entries = $0.locations }
            )
            .store(in: &cancellable)
    }

    func add(location: WeatherLocation) {
        service.add(location: location)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { self.handle(completion: $0) },
                receiveValue: { _ in self.refresh() }
            )
            .store(in: &cancellable)
    }

    func remove(location: WeatherLocation) {
        service.remove(locationID: location.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { self.handle(completion: $0) },
                receiveValue: { _ in self.refresh() }
            )
            .store(in: &cancellable)
    }

    fileprivate func handle(completion: Subscribers.Completion<ServiceError>) {
        switch completion {
        case .failure(let error): self.displayError = self.errorString(error: error)
        case .finished: break
        }
    }

    fileprivate func errorString(error: Error) -> String? {
        let serviceError = error as? ServiceError
        return serviceError?.text ?? error.localizedDescription
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
