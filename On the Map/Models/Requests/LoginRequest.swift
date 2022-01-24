//
//  LoginRequest.swift
//  On the Map
//
//  Created by Min Thet Maung on 30/04/2021.
//

import Foundation

struct LoginRequest: Codable {
    let udacity: Udacity
}

struct Udacity: Codable {
    let username: String
    let password: String
}
