//
//  WeatherService.swift
//  CodeTest
//
//  Created by Tatiana Bernatskaya on 2020-12-22.
//  Copyright © 2020 Emmanuel Garnier. All rights reserved.
//

import Foundation
import Combine

protocol WeatherService {
    func fetchLocations() -> AnyPublisher<LocationsResult, ServiceError>
    func add(location: WeatherLocation) -> AnyPublisher<WeatherLocation, ServiceError>
    func remove(locationID: String) -> AnyPublisher<Data, ServiceError>
}

struct WeatherServiceImplementation: WeatherService {

    private var apiKey: String {
        guard let apiKey = UserDefaults.standard.string(forKey: "API_KEY") else {
            let key = UUID().uuidString
            UserDefaults.standard.set(key, forKey: "API_KEY")
            return key
        }
        return apiKey
    }

    private let baseURL = "https://app-code-test.kry.pet/locations/"

    func fetchLocations() -> AnyPublisher<LocationsResult, ServiceError> {
        URLSession.shared.dataTaskPublisher(for: request(url: baseURL))
            .map { $0.data }
            .decode(type: LocationsResult.self, decoder: JSONDecoder())
            .mapError { _ in return ServiceError.generic }
            .eraseToAnyPublisher()
    }

    func add(location: WeatherLocation) -> AnyPublisher<WeatherLocation, ServiceError> {
        var urlRequest = request(url: baseURL, method: "POST")
        urlRequest.httpBody = try! JSONEncoder().encode(location)

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: WeatherLocation.self, decoder: JSONDecoder())
            .mapError { _ in return ServiceError.cannotAddLocation }
            .eraseToAnyPublisher()
    }

    func remove(locationID: String) -> AnyPublisher<Data, ServiceError> {
        let urlRequest = request(url: baseURL.appending(locationID), method: "DELETE")

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .mapError { _ in return ServiceError.cannotRemoveLocation }
            .eraseToAnyPublisher()
    }
}

fileprivate extension WeatherServiceImplementation {
    func request(url: String, method: String? = "GET") -> URLRequest {
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        urlRequest.httpMethod = method

        return urlRequest
    }
}

enum ServiceError: Error {
    case generic, cannotAddLocation, cannotRemoveLocation
}
