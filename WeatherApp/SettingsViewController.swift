import UIKit
import Auth0
import SimpleKeychain
import Foundation

@available(iOS 10.0, *)
class SettingsViewController: UIViewController {
    @IBOutlet weak var newName: UITextField!
    @IBOutlet weak var formatTemperature: UISegmentedControl!
    @IBAction func getBackWithoutSaving(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: false)
        self.performSegue(withIdentifier: "getBackToWeather", sender: self)
    }

    
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "backToHome", sender: nil)
    }
    
    @IBAction func eraseAppPressed(_ sender: UIButton) {        
        UserOperations().deleteAllContextObject()
        self.performSegue(withIdentifier: "backToHome", sender: nil)
    }

    
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        
        let user = UserOperations().getUser(access_token: ((SessionManager.shared.credentials?.accessToken)!))
        if (newName.text == "") {
            newName.text = user!.username
        }
        UserOperations().editUser(access_token: (user?.access_token)!, temperature_format: Int16(formatTemperature!.selectedSegmentIndex), location: (user?.location) as! String, username: newName.text!)
        
        self.navigationController?.popViewController(animated: false)
        self.performSegue(withIdentifier: "getBackToWeather", sender: self)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = UserOperations().getUser(access_token: ((SessionManager.shared.credentials?.accessToken)!))
        self.newName.placeholder = user!.username
        self.formatTemperature.selectedSegmentIndex = Int(user!.temperature_format)
    }
}
