import UIKit
import Auth0
import SimpleKeychain

@available(iOS 10.0, *)
class LoggedViewController: UIViewController {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var greetMessage: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let profile_name = SessionManager.shared.profile?.name

        if (UserOperations().getUser(access_token: (SessionManager.shared.credentials?.accessToken)!) == nil) {
            print("User does not exist in database. Creating")
            UserOperations().insertUser(access_token: (SessionManager.shared.credentials?.accessToken)!, temperature_format: 0, location: "", username: profile_name!)
            self.greetMessage.text = "Welcome, \(profile_name!) ! 🌞"
        }
        else {
            self.greetMessage.text = "Welcome back, \(UserOperations().getUser(access_token: ((SessionManager.shared.credentials?.accessToken)!))!.username!) ! 🌞"
        }
        // IF LOGGED
        guard let pictureURL = SessionManager.shared.profile?.picture else { return }
        let task = URLSession.shared.dataTask(with: pictureURL) { (data, response, error) in
            guard let data = data , error == nil else { return }
            DispatchQueue.main.async {
                self.profilePicture.image = UIImage(data: data)
            }
        }
        task.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if (UserOperations().getUser(access_token: ((SessionManager.shared.credentials?.accessToken)!))!.location == "") {
                self.performSegue(withIdentifier: "MoveToLocation", sender: nil)
            }
            else {
                self.performSegue(withIdentifier: "moveToWeather", sender: nil)
            }
        }
    }
}
