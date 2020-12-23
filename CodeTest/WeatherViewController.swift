//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import UIKit

class WeatherViewController: UITableViewController {

    private var viewModel: WeatherViewModel!

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    static func create(viewModel: WeatherViewModel) -> WeatherViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! WeatherViewController

        viewController.viewModel = viewModel
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        refresh()
    }
}

fileprivate extension WeatherViewController {
    func setup() {
        title = "Weather Code Test"
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.addTarget(self, action: #selector(addLocation), for: .touchUpInside)

        let rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem

        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
        ])
    }

    func refresh() {
        if !spinner.isAnimating { spinner.startAnimating() }
        viewModel.refresh(completion: { self.handleUpdate(success: $0, error: $1) })
    }

    func handleUpdate(success: Bool, error: String?) {
        spinner.stopAnimating()
        if success {
            UIView.transition(with: tableView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.tableView.reloadData() })
        }
        else { displayError(error: error ?? "Ooops! Something went wrong") }
    }

    @objc func addLocation() {
        let location = WeatherLocation.randomElement()
        if !spinner.isAnimating { spinner.startAnimating() }
        viewModel.add(location: location, completion: { self.handleUpdate(success: $0, error: $1) })
    }

    func displayError(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.refresh() }))
        self.present(alertController, animated: true)
    }
}

extension WeatherViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseIdentifier, for: indexPath) as! LocationTableViewCell

        let entry = viewModel.entries[indexPath.row]
        cell.setup(entry)

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if !spinner.isAnimating { spinner.startAnimating() }
        viewModel.remove(index: indexPath.row, completion: { self.handleUpdate(success: $0, error: $1) })
    }
}

extension WeatherLocation {
    static func randomElement() -> WeatherLocation {
        let cities = ["New York", "Hong Knog", "Kiev", "Moscow", "Helsinki", "Tallin", "Madrid", "Tokio", "Kyoto"]

        return WeatherLocation(id: UUID().uuidString,
                               name: cities.randomElement()!,
                               status: WeatherLocation.Status.allCases.randomElement()!,
                               temperature: Int.random(in: -20..<40))
    }
}
