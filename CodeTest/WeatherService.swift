//
//  WeatherService.swift
//  CodeTest
//
//  Created by Tatiana Bernatskaya on 2020-12-22.
//  Copyright © 2020 Emmanuel Garnier. All rights reserved.
//

import Foundation

protocol WeatherService {
    func fetchLocations(completion: @escaping (Result<LocationsResult, Error>) -> ())
    func add(location: WeatherLocation, completion: @escaping (Result<Data, Error>) -> ())
    func remove(locationID: String, completion: @escaping (Result<Data, Error>) -> ())
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

    func fetchLocations(completion: @escaping (Result<LocationsResult, Error>) -> ()) {
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        return fetch(request: urlRequest, defaultError: ServiceError.generic,
                     completion: { result in
                        switch result {
                        case .success(let data): decode(data: data, completion: completion)
                        case .failure(let error): completion(.failure(error))
                        }
                     })
    }

    func add(location: WeatherLocation, completion: @escaping (Result<Data, Error>) -> ()) {
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        urlRequest.httpMethod = "POST"

        do {
            urlRequest.httpBody = try JSONEncoder().encode(location)
        } catch {
            return completion(.failure(error))
        }

        return fetch(request: urlRequest,
                     defaultError: ServiceError.cannotAddLocation,
                     completion: completion)
    }

    func remove(locationID: String, completion: @escaping (Result<Data, Error>) -> ()) {
        var urlRequest = URLRequest(url: URL(string: baseURL.appending(locationID))!)
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        urlRequest.httpMethod = "DELETE"

        return fetch(request: urlRequest,
                     defaultError: ServiceError.cannotRemoveLocation,
                     completion: completion)
    }
}

fileprivate extension WeatherServiceImplementation {

    private func fetch(request: URLRequest, defaultError: Error, completion: @escaping (Result<Data, Error>) -> ()) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard
                    error == nil,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                else {
                    return completion(.failure(error ?? defaultError))
                }
                return completion(.success(data))
            }
        }
        task.resume()
    }

    private func decode<T: Decodable>(data: Data, completion: @escaping (Result<T, Error>) -> ()) {
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            completion(.success(model))
        }
        catch { completion(.failure(error)) }
    }
}

enum ServiceError: Error {
    case generic, cannotAddLocation, cannotRemoveLocation
}
