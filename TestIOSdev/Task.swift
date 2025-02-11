//
//  Task.swift
//  TestIOSdev
//
//  Created by Дмитрий Куприянов on 10.02.25.
//

import Foundation

struct Task: Identifiable, Codable {
    var id: String  // task
    var title: String
    var description: String
    var colorCode: String

    enum CodingKeys: String, CodingKey {
        case id = "task"
        case title
        case description
        case colorCode = "colorCode"
    }
}
