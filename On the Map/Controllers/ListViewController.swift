//
//  ListViewController.swift
//  On the Map
//
//  Created by Min Thet Maung on 29/04/2021.
//

import UIKit

class ListViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: - LifeCyle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetData()
    }
    
    
    
    // MARK: - IBActions

    @IBAction private func resetData() {
        APIClient.requestStudentLocations { (studentsInformation, error) in
            if error != nil {
                self.showMessage(title: "Download Fail", message: "Fail to download student locations!")
            } else {
                StudentInformationModel.studentsInformation = studentsInformation
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        APIClient.deleteSession { (success, error) in
            if success {
                self.dismiss(animated: true)
            }
        }
    }
    
}



// MARK: - UITableViewDataSource

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        StudentInformationModel.studentsInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        let studentInformation = StudentInformationModel.studentsInformation[indexPath.row]
        let firstName = studentInformation.firstName
        let lastName = studentInformation.lastName
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = "\(firstName) \(lastName)"
        if let mediaURL = studentInformation.mediaURL {
            cell.detailTextLabel?.text = mediaURL
        }
        cell.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        return cell
    }
    
}



// MARK: - UITableViewDelegate

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let mediaUrlString = StudentInformationModel.studentsInformation[indexPath.row].mediaURL,
              let url = URL(string: mediaUrlString)
              else { return }
        let app = UIApplication.shared
        app.openURL(url)
    }
}
