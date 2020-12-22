//
//  WeatherService.swift
//  CodeTest
//
//  Created by Tatiana Bernatskaya on 2020-12-22.
//  Copyright © 2020 Emmanuel Garnier. All rights reserved.
//

import Foundation

protocol WeatherService {
    func fetchLocations(completion: @escaping (Result<[WeatherLocation], Error>) -> ())
    func add(location: WeatherLocation, completion: @escaping (Result<Void, Error>) -> ())
}

struct WeatherServiceImplementation: WeatherService {
    private struct LocationsResult: Decodable {
        var locations: [WeatherLocation]
    }

    private var apiKey: String {
        guard let apiKey = UserDefaults.standard.string(forKey: "API_KEY") else {
            let key = UUID().uuidString
            UserDefaults.standard.set(key, forKey: "API_KEY")
            return key
        }
        return apiKey
    }

    func fetchLocations(completion: @escaping (Result<[WeatherLocation], Error>) -> ()) {
        var urlRequest = URLRequest(url: URL(string: "https://app-code-test.kry.pet/locations")!)
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        URLSession(configuration: .default).dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      error == nil
                else {
                    return completion(.failure(error ?? ServiceError.generic))
                }
                do {
                    let result = try JSONDecoder().decode(LocationsResult.self, from: data)
                    completion(.success(result.locations))
                } catch {
                    return completion(.failure(error))
                }
            }
        }.resume()
    }

    func add(location: WeatherLocation, completion: @escaping (Result<Void, Error>) -> ()) {
        var urlRequest = URLRequest(url: URL(string: "https://app-code-test.kry.pet/locations")!)
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        urlRequest.httpMethod = "POST"

        do {
            urlRequest.httpBody = try JSONEncoder().encode(location)
        } catch {
            return completion(.failure(error))
        }

        URLSession(configuration: .default).dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                guard let _ = data,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      error == nil
                else {
                    return completion(.failure(error ?? ServiceError.cannotAddLocation))
                }
                completion(.success(()))
            }
        }.resume()
    }
}

enum ServiceError: Error {
    case generic, cannotAddLocation
}
