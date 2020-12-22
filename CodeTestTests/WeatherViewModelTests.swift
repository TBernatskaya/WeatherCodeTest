//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import XCTest
@testable import CodeTest

class WeatherViewModelTests: XCTestCase {
    func testRefreshSuccess() {
        let mockService = WeatherServiceMock()
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.refresh(completion: { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            XCTAssertEqual(viewModel.entries.count, 2)
        })
    }

    func testRefreshFailed() {
        let mockService = WeatherServiceMock(returnsFailure: true)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.refresh(completion: { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            XCTAssertEqual(error, ServiceError.generic.localizedDescription)
            XCTAssertEqual(viewModel.entries.count, 0)
        })
    }

    func testAddLocationSuccess() {
        let mockService = WeatherServiceMock()
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.add(location: WeatherLocation(id: UUID().uuidString,
                                                name: "Test location 3",
                                                status: .partlySunnyRain,
                                                temperature: 20), completion: { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
        })
    }

    func testAddLocationFailed() {
        let mockService = WeatherServiceMock(returnsFailure: true)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.add(location: WeatherLocation(id: UUID().uuidString,
                                                name: "Test location 3",
                                                status: .partlySunnyRain,
                                                temperature: 20), completion: { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            XCTAssertEqual(error, ServiceError.cannotAddLocation.localizedDescription)
        })
    }
}

fileprivate struct WeatherServiceMock: WeatherService {
    var returnsFailure: Bool = false

    func fetchLocations(completion: @escaping (Result<[WeatherLocation], Error>) -> ()) {
        guard returnsFailure
        else {
            return completion(.success([WeatherLocation(id: UUID().uuidString,
                                                        name: "Test location 1",
                                                        status: .barelySunny,
                                                        temperature: 10),
                                        WeatherLocation(id: UUID().uuidString,
                                                        name: "Test location 2",
                                                        status: .cloudy,
                                                        temperature: 15)]))
        }
        return completion(.failure(ServiceError.generic))
    }

    func add(location: WeatherLocation, completion: @escaping (Result<Void, Error>) -> ()) {
        guard returnsFailure
        else { return completion(.success(())) }
        return completion(.failure(ServiceError.cannotAddLocation))
    }
}
