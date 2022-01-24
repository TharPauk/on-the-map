//
//  FindLocationViewController.swift
//  On the Map
//
//  Created by Min Thet Maung on 30/04/2021.
//

import UIKit
import MapKit

class FindLocationViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    var userInfo: UserInfo?
    var locationString: String!
    var websiteUrl: String!
    var location: CLLocationCoordinate2D!
    
    
    
    // MARK: - LifeCycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCenterLocation()
        setupPinPointsOnMap()
    }
    
    
    
    // MARK: - IBActions
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        requestUserInfo()
    }
    
    
    
    // MARK: - Networking Related Functions
    
    private func requestUserInfo() {
        APIClient.requestUserInfo(completion: handleRequestUserInfo(userInfo:error:))
    }
    
    private func handleRequestUserInfo(userInfo: UserInfo?, error: Error?) {
        if let userInfo = userInfo {
            let body = StudentInformation(objectId: nil,uniqueKey: APIClient.Auth.userId, firstName: userInfo.firstName, lastName: userInfo.lastName, mapString: locationString, mediaURL: websiteUrl, latitude: location.latitude, longitude: location.longitude, createdAt: nil, updatedAt: nil)
            APIClient.postStudentLocation(body: body, completion: handleStudentLocationResponse(success:error:))
        } else {
            showMessage(title: "Posting Fail", message: "Fail to post the user location. Please try again later.")
        }
    }
    
    private func handleStudentLocationResponse(success: Bool, error: Error?) {
        if let error = error {
            self.showMessage(title: "Error", message: "\(error.localizedDescription)")
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    
    // MARK: - Pin Related Functions
    
    private func setupPinPointsOnMap() {
        guard let location = self.location else { return }
        let annotation = createAnnotation(location: location)
        mapView.addAnnotation(annotation)
    }
    
    private func createAnnotation(location: CLLocationCoordinate2D) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = locationString
        return annotation
    }
    
    private func createPinView(annotation: MKAnnotation, reuseIdentifier: String) -> MKPinAnnotationView {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        pinView.canShowCallout = true
        pinView.pinTintColor = .systemBlue
        return pinView
    }
    
    
    
    // MARK: - Helper Functions
    
    private func setCenterLocation() {
        let radius: CLLocationDistance = 10000.0
        let region = MKCoordinateRegion(center: location, latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(region, animated: true)
    }
    
}


// MARK: - MKMapViewDelegate

extension FindLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinId = "pinId"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = createPinView(annotation: annotation, reuseIdentifier: pinId)
            return pinView
        }
        
        pinView?.annotation = annotation
        return pinView
    }
}
