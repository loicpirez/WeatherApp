import UIKit
import Auth0
import SimpleKeychain
import CoreData


class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - IBAction

    @IBAction func showLoginController(_ sender: UIButton) {
        self.checkToken()
    }

    // MARK: - Private
    
    fileprivate func showLogin() {
        guard let clientInfo = plistValues(bundle: Bundle.main) else { return }
        Auth0.webAuth()
            .parameters(["prompt":"login"])
            .scope("openid profile offline_access")
            .audience("https://" + clientInfo.domain + "/userinfo")
            .start {
                switch $0 {
                case .failure(let error):
                    print("Error: \(error)")
                case .success(let credentials):
                    if(!SessionManager.shared.store(credentials: credentials)) {
                        print("Failed to store credentials")
                    } else {
                        SessionManager.shared.retrieveProfile { error in
                            DispatchQueue.main.async {
                                guard error == nil else {
                                    print("Failed to retrieve profile: \(String(describing: error))")
                                    return self.showLogin()
                                }
                                self.performSegue(withIdentifier: "ShowProfileAnimated", sender: nil)
                            }
                        }
                    }
                }
        }
    }

    fileprivate func checkToken() {
        let loadingAlert = UIAlertController.loadingAlert()
        loadingAlert.presentInViewController(self)
        SessionManager.shared.renewAuth { error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    guard error == nil else {
                        print("Failed to retrieve credentials: \(String(describing: error))")
                        return self.showLogin()
                    }
                    SessionManager.shared.retrieveProfile { error in
                        DispatchQueue.main.async {
                            guard error == nil else {
                                print("Failed to retrieve profile: \(String(describing: error))")
                                return self.showLogin()
                            }
                            self.performSegue(withIdentifier: "ShowProfileAnimated", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
}
