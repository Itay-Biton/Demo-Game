import UIKit

class OrientationAwareNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .all
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
