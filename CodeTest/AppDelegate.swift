//
//  Copyright © Webbhälsa AB. All rights reserved.
//

import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let viewModel = WeatherViewModel(service: WeatherServiceImplementation())
        let weatherView = WeatherView(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: UIHostingController(rootView: weatherView))

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

