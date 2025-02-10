//
//  Token.swift
//  TestIOSdev
//
//  Created by Дмитрий Куприянов on 10.02.25.
//

struct TokenResponse: Codable {
    struct OAuth: Codable {
        let access_token: String
    }
    let oauth: OAuth
}
