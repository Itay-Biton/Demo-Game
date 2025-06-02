import UIKit
import CoreLocation

class MenuViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var username_LBL: UILabel!
    @IBOutlet weak var hello_LBL: UILabel!
    @IBOutlet weak var name_input: UITextField!
    @IBOutlet weak var east_globe: UIImageView!
    @IBOutlet weak var west_globe: UIImageView!
    @IBOutlet weak var start_BTN: UIButton!

    static let usernameKey = "SavedUsername"
    var isInEditMode = false
    
    var userIsLeftSide = false

    let locationManager = CLLocationManager()
    let middleLongitude: CLLocationDegrees = 34.817549168324334
    var userLocationAvailable = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        addTapToEdit()
        setupKeyboardDismissRecognizer()
        configureLocationManager()
    }

    func setupInitialUI() {
        if let savedName = UserDefaults.standard.string(forKey: MenuViewController.usernameKey), !savedName.isEmpty {
            enterDisplayMode(with: savedName)
        } else {
            enterEditMode()
        }
    }

    func enterEditMode() {
        isInEditMode = true
        hello_LBL.text = "Enter your name"
        name_input.isHidden = false
        name_input.isEnabled = true
        username_LBL.isHidden = true
        start_BTN.setTitle("Save Username", for: .normal)
    }

    func enterDisplayMode(with name: String) {
        isInEditMode = false
        hello_LBL.text = "Hello"
        username_LBL.text = name
        name_input.isHidden = true
        username_LBL.isHidden = false
        start_BTN.setTitle("START", for: .normal)
    }

    func addTapToEdit() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(usernameTapped))
        username_LBL.isUserInteractionEnabled = true
        username_LBL.addGestureRecognizer(tapGesture)
    }

    @objc func usernameTapped() {
        if (!userLocationAvailable) {
            return
        }
        enterEditMode()
        name_input.text = username_LBL.text
    }

    func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard userLocationAvailable else {
            showLocationDeniedAlert()
            return
        }

        if isInEditMode {
            let name = name_input.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if name.isEmpty {
                showEmptyNameAlert()
                return
            }

            UserDefaults.standard.set(name, forKey: MenuViewController.usernameKey)
            enterDisplayMode(with: name)
        } else {
            performSegue(withIdentifier: "toGame", sender: self)
        }
    }

    func showEmptyNameAlert() {
        let alert = UIAlertController(title: "Name Required", message: "Please enter a name before continuing.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showLocationDeniedAlert() {
        let alert = UIAlertController(title: "Location Required", message: "Please allow location access to continue.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGame",
           let gameVC = segue.destination as? GameViewController {
            gameVC.userIsLeftSide = userIsLeftSide
        }
    }

    // MARK: - Location Handling

    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    // iOS 14+ authorization callback
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            disableStartButtonDueToLocation()
        case .notDetermined:
            break // waiting on user input
        @unknown default:
            break
        }
    }

    // iOS 13 and below support
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else if status == .denied || status == .restricted {
            disableStartButtonDueToLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        userLocationAvailable = true
        start_BTN.isEnabled = true

        let userLongitude = location.coordinate.longitude

        if userLongitude > middleLongitude {
            // East
            userIsLeftSide = false
            east_globe.alpha = 1.0
            west_globe.alpha = 0.5
        } else {
            // West
            userIsLeftSide = true
            east_globe.alpha = 0.5
            west_globe.alpha = 1.0
        }

        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        disableStartButtonDueToLocation()
    }

    func disableStartButtonDueToLocation() {
        userLocationAvailable = false
        start_BTN.isEnabled = false
        start_BTN.setTitle("Location Needed", for: .normal)
    }
}
