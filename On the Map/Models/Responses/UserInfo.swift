//
//  UserInfoResponse.swift
//  On the Map
//
//  Created by Min Thet Maung on 01/05/2021.
//

import Foundation

class UserInfo: Codable {
    let firstName: String
    let lastName: String
    let uniqueKey: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueKey = "key"
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
