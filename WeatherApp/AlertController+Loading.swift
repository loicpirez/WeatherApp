import UIKit

extension UIAlertController {
    
    static func loadingAlert() -> UIAlertController {
        return UIAlertController(title: "Loading", message: "Please, wait...", preferredStyle: .alert)
    }
    
    func presentInViewController(_ viewController: UIViewController) {
        viewController.present(self, animated: true, completion: nil)
    }

}
