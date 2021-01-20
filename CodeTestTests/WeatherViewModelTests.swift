//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import XCTest
import Combine
@testable import CodeTest

class WeatherViewModelTests: XCTestCase {

    fileprivate let testData = TestData()

    override func setUp() {
        super.setUp()
        testData.reset()
    }

    func testRefreshSuccess() {
        let mockService = WeatherServiceMock(testData: testData)
        let viewModel = WeatherViewModel(service: mockService)
        viewModel.refresh()

        // TODO: revisit this
        DispatchQueue.main.async {
            XCTAssertEqual(viewModel.entries.count, 2)
            XCTAssertNil(viewModel.displayError)
        }
    }

    func testRefreshFailed() {
        let mockService = WeatherServiceMock(returnsFailure: true, testData: testData)
        let viewModel = WeatherViewModel(service: mockService)
        viewModel.refresh()

        DispatchQueue.main.async {
            XCTAssertEqual(viewModel.entries.count, 0)
            XCTAssertEqual(viewModel.displayError, ServiceError.generic.text)
        }
    }

    func testAddLocationSuccess() {
        let mockService = WeatherServiceMock(testData: testData)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.add(location: WeatherLocation(id: UUID().uuidString,
                                                name: "Test location 3",
                                                status: .partlySunnyRain,
                                                temperature: 20))

        DispatchQueue.main.async {
            XCTAssertEqual(viewModel.entries.count, 3)
            XCTAssertNil(viewModel.displayError)
        }
    }

    func testAddLocationFailed() {
        let mockService = WeatherServiceMock(returnsFailure: true, testData: testData)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.add(location: WeatherLocation(id: UUID().uuidString,
                                                name: "Test location 3",
                                                status: .partlySunnyRain,
                                                temperature: 20))

        DispatchQueue.main.async {
            XCTAssertEqual(viewModel.entries.count, 0)
            XCTAssertEqual(viewModel.displayError, ServiceError.cannotAddLocation.text)
        }

    }

    func testRemoveLocationSuccess() {
        let mockService = WeatherServiceMock(testData: testData)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.refresh()
        viewModel.remove(location: testData.testLocations.first!)

        DispatchQueue.main.async {
            XCTAssertEqual(viewModel.entries.count, 1)
            XCTAssertNil(viewModel.displayError)
        }
    }

    func testRemoveLocationFailed() {
        let mockService = WeatherServiceMock(returnsFailure: true, testData: testData)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.remove(location: testData.testLocations.first!)

        DispatchQueue.main.async {
            XCTAssertEqual(viewModel.entries.count, 0)
            XCTAssertEqual(viewModel.displayError, ServiceError.cannotRemoveLocation.text)
        }
    }
}

fileprivate class TestData {
    var testLocations = [WeatherLocation]()

    func reset() {
        testLocations = [WeatherLocation(id: UUID().uuidString,
                                         name: "Test location 1",
                                         status: .barelySunny,
                                         temperature: 10),
                         WeatherLocation(id: UUID().uuidString,
                                         name: "Test location 2",
                                         status: .cloudy,
                                         temperature: 15)]
    }
}

fileprivate struct WeatherServiceMock: WeatherService {
    var returnsFailure: Bool = false
    var testData: TestData

    func fetchLocations() -> AnyPublisher<LocationsResult, ServiceError> {
        if returnsFailure {
            return Fail<LocationsResult, ServiceError>(error: ServiceError.generic).eraseToAnyPublisher()
        }
        else {
            return Just(LocationsResult(locations: testData.testLocations))
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        }
    }

    func add(location: WeatherLocation) -> AnyPublisher<WeatherLocation, ServiceError> {
        if returnsFailure {
            return Fail<WeatherLocation, ServiceError>(error: ServiceError.cannotAddLocation).eraseToAnyPublisher()
        }
        else {
            testData.testLocations.append(location)
            return Just(location)
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        }
    }

    func remove(locationID: String) -> AnyPublisher<Data, ServiceError>  {
        if returnsFailure {
            return Fail<Data, ServiceError>(error: ServiceError.cannotRemoveLocation).eraseToAnyPublisher()
        }
        else {
            let index = testData.testLocations.firstIndex(where: { $0.id == locationID })!
            testData.testLocations.remove(at: index)
            return Just(Data())
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        }
    }
}
