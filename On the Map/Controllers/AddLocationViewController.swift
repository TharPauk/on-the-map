//
//  AddLocationViewController.swift
//  On the Map
//
//  Created by Min Thet Maung on 30/04/2021.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var userInfo: UserInfo?
    private var coordinate: CLLocationCoordinate2D!
    
    
    
    // MARK: - LifeCycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        APIClient.requestUserInfo { (userInfo, error) in
            self.userInfo = userInfo
        }
    }
    
    
    
    // MARK: - IBActions
    
    @IBAction func findLocationButtonPressed(_ sender: Any) {
        
        guard let location = locationTextField.text,
              location.count > 0,
              let website = websiteTextField.text,
              website.count > 0
        else {
            self.showMessage(title: "Empty fields!", message: "Location or website should not be empty.")
            return
        }
        setSearchingState(isSearching: true)
        convertAddressToCoordinate(addressString: location, completion: handleGeocoding(coordinate:error:))
    }
    
    
    
    // MARK: - Geocoding Related Functions
    
    private func convertAddressToCoordinate(addressString: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            completion(placemarks?.first?.location?.coordinate, nil)
        }
    }
    
    private func handleGeocoding(coordinate: CLLocationCoordinate2D?, error: Error?) {
        setSearchingState(isSearching: false)
        if error != nil {
            self.showMessage(title: "No Location Found", message: "The location you entered is not found! Please try another location.")
        } else {
            self.coordinate = coordinate
            self.performSegue(withIdentifier: "FindLocation", sender: nil)
        }
    }
    
    
    
    // MARK: - Segue Function
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FindLocation" {
            let findLocationVC = segue.destination as! FindLocationViewController
            findLocationVC.userInfo = self.userInfo
            findLocationVC.locationString = locationTextField.text
            findLocationVC.websiteUrl = websiteTextField.text
            findLocationVC.location = self.coordinate
        }
    }
    
    
    
    // MARK: - Helper Functions

    private func setSearchingState(isSearching: Bool) {
        if isSearching {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        [websiteTextField, locationTextField, findLocationButton].forEach{ $0?.isEnabled = !isSearching }
    }
}
