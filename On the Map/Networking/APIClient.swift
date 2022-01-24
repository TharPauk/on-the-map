//
//  Client.swift
//  On the Map
//
//  Created by Min Thet Maung on 29/04/2021.
//

import UIKit

class APIClient {
    
    struct Auth {
        static var userId: String = ""
    }
    
    // MARK: - Endpoints
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/"
        static let signUpUrl = "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com"
        
        case createSession
        case getUserInfo(String)
        case getStudentLocations
        case postStudentLocation
        case getAStudentLocation(String)
        
        var stringValue: String {
            switch self {
            case .createSession: return Endpoints.base + "session"
            case .getUserInfo(let userId): return Endpoints.base + "users/\(userId)"
            case .getStudentLocations: return Endpoints.base + "StudentLocation?limit=100&order=-updatedAt"
            case .postStudentLocation: return Endpoints.base + "StudentLocation"
            case .getAStudentLocation(let uniqueKey): return Endpoints.base + "StudentLocation?uniqueKey=\(uniqueKey)"
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
    }
    
    // MARK: - Reusable request functions
    
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, isNeedSubset: Bool? = false, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject: ResponseType
                if isNeedSubset == true {
                    let range = 5..<data.count
                    let subsettedData = data.subdata(in: range)
                    responseObject = try decoder.decode(ResponseType.self, from: subsettedData)
                } else {
                    responseObject = try decoder.decode(ResponseType.self, from: data)
                }
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func taskForPostRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, isNeedSubset: Bool? = false, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow?.rootViewController?.showMessage(title: "Connection Fail", message: "No Internet Connection!")
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject: ResponseType
                if isNeedSubset == true {
                    let range = 5..<data.count
                    let subsettedData = data.subdata(in: range)
                    responseObject = try decoder.decode(ResponseType.self, from: subsettedData)
                } else {
                    responseObject = try decoder.decode(ResponseType.self, from: data)
                }
                
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    
    class func taskForDeleteRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let range = 5..<data.count
                let subsettedData = data.subdata(in: range)
                let responseObject = try decoder.decode(ResponseType.self, from: subsettedData)
                
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func requestUserInfo(completion: @escaping (UserInfo?, Error?) -> Void) {
        taskForGetRequest(url: Endpoints.getUserInfo(Auth.userId).url, isNeedSubset: true, responseType: UserInfo.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    
    
    // MARK: - Student Location Related Request Functions
    
    class func requestStudentLocations(completion: @escaping ([StudentInformation], Error?) -> Void) {
        taskForGetRequest(url: Endpoints.getStudentLocations.url, responseType: StudentsInformationResponse.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func postStudentLocation(body: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        taskForPostRequest(url: Endpoints.postStudentLocation.url, body: body, responseType: StudentInformationResponse.self) { (response, error) in
            if error == nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    
    
    // MARK: - Session Related Request Functions
    
    class func createSession(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(udacity: Udacity(username: username, password: password))
        taskForPostRequest(url: Endpoints.createSession.url, isNeedSubset: true, body: body, responseType: LoginResponse.self) { (response, error) in
            if let resp = response {
                Auth.userId = resp.account.key
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func deleteSession(completion: @escaping (Bool, Error?) -> Void) {
        taskForDeleteRequest(url: Endpoints.createSession.url, responseType: LogoutResponse.self) { (reponse, error) in
            if error == nil {
                Auth.userId = ""
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
}
