//
//  ViewController.swift
//  On the Map
//
//  Created by Min Thet Maung on 29/04/2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    // MARK: - LifeCycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetData()
    }
    
    
    
    // MARK: - IBActions

    @IBAction private func resetData() {
        APIClient.requestStudentLocations(completion: handleStudentLocationsRequest(studentsInformation:error:))
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        APIClient.deleteSession { (success, error) in
            if success {
                self.dismiss(animated: true)
            }
        }
    }
    
    
    
    
    // MARK: - Request Funcion
    
    private func handleStudentLocationsRequest(studentsInformation: [StudentInformation], error: Error?) {
        if error != nil {
            showMessage(title: "Download Fail", message: "Fail to download student locations!")
        } else {
            StudentInformationModel.studentsInformation = studentsInformation
            setupPinPointsOnMap()
        }
    }
    
    
    
    // MARK: - Pin Related Functions
    
    private func setupPinPointsOnMap() {
        var annotations = [MKPointAnnotation]()
        StudentInformationModel.studentsInformation.forEach {
            let annotation = createAnnotation(studentInformation: $0)
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    private func createCoordinate(latitude: Double, longitude: Double) -> CLLocationCoordinate2D {
        let lat = CLLocationDegrees(latitude)
        let lon = CLLocationDegrees(longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        return coordinate
    }
    
    private func createAnnotation(studentInformation: StudentInformation) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = createCoordinate(latitude: studentInformation.latitude, longitude: studentInformation.longitude)
        annotation.title = "\(studentInformation.firstName) \(studentInformation.lastName)"
        annotation.subtitle = studentInformation.mediaURL
        return annotation
    }
    
    private func createPinView(annotation: MKAnnotation, reuseIdentifier: String) -> MKPinAnnotationView {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        pinView.canShowCallout = true
        pinView.pinTintColor = .systemBlue
        pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pinView
    }
    
    
}



// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                if let url = URL(string: toOpen) {
                    app.openURL(url)
                }
            }
        }
    }
    
}
