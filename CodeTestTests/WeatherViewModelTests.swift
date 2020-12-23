//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import XCTest
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

        viewModel.refresh(completion: { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            XCTAssertEqual(viewModel.entries.count, 2)
        })
    }

    func testRefreshFailed() {
        let mockService = WeatherServiceMock(returnsFailure: true, testData: testData)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.refresh(completion: { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            XCTAssertEqual(error, ServiceError.generic.text)
            XCTAssertEqual(viewModel.entries.count, 0)
        })
    }

    func testAddLocationSuccess() {
        let mockService = WeatherServiceMock(testData: testData)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.add(location: WeatherLocation(id: UUID().uuidString,
                                                name: "Test location 3",
                                                status: .partlySunnyRain,
                                                temperature: 20), completion: { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            XCTAssertEqual(viewModel.entries.count, 3)
        })
    }

    func testAddLocationFailed() {
        let mockService = WeatherServiceMock(returnsFailure: true, testData: testData)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.add(location: WeatherLocation(id: UUID().uuidString,
                                                name: "Test location 3",
                                                status: .partlySunnyRain,
                                                temperature: 20), completion: { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            XCTAssertEqual(error, ServiceError.cannotAddLocation.text)
            XCTAssertEqual(viewModel.entries.count, 0)
        })
    }

    func testRemoveLocationSuccess() {
        let mockService = WeatherServiceMock(testData: testData)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.refresh(completion: { _,_ in })

        viewModel.remove(index: 0, completion: { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            XCTAssertEqual(viewModel.entries.count, 1)
        })
    }

    func testRemoveLocationFailed() {
        let mockService = WeatherServiceMock(returnsFailure: true, testData: testData)
        let viewModel = WeatherViewModel(service: mockService)

        viewModel.remove(index: 0, completion: { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            XCTAssertEqual(error, ServiceError.cannotRemoveLocation.text)
            XCTAssertEqual(viewModel.entries.count, 0)
        })
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

    func fetchLocations(completion: @escaping (Result<LocationsResult, Error>) -> ()) {
        if returnsFailure {
            return completion(.failure(ServiceError.generic))
        }
        else {
            return completion(.success(LocationsResult(locations: testData.testLocations)))
        }
    }

    func add(location: WeatherLocation, completion: @escaping (Result<Data, Error>) -> ()) {
        if returnsFailure {
            return completion(.failure(ServiceError.cannotAddLocation))
        }
        else {
            testData.testLocations.append(location)
            return completion(.success(Data()))
        }
    }

    func remove(locationID: String, completion: @escaping (Result<Data, Error>) -> ()) {
        if returnsFailure {
            return completion(.failure(ServiceError.cannotRemoveLocation))
        }
        else {
            let index = testData.testLocations.firstIndex(where: { $0.id == locationID })!
            testData.testLocations.remove(at: index)
            return completion(.success(Data()))
        }
    }
}
