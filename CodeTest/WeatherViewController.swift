//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import UIKit

class WeatherViewController: UITableViewController {

    private var viewModel: WeatherViewModel!

    static func create(viewModel: WeatherViewModel) -> WeatherViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! WeatherViewController

        viewController.viewModel = viewModel
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        viewModel.refresh(completion: { success, error in
            if success { self.tableView.reloadData() }
            else { self.displayError(error: error ?? "Ooops! Something went wrong") }
        })
    }
}

fileprivate extension WeatherViewController {
    private func setup() {
        title = "Weather Code Test"
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }

    private func displayError(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
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
}
