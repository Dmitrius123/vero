//
//  Task.swift
//  TestIOSdev
//
//  Created by Дмитрий Куприянов on 10.02.25.
//

import Foundation

struct Task: Identifiable, Codable {
    var id: String  // Используем уникальный идентификатор, например, task (можно использовать task как id)
    var title: String
    var description: String
    var colorCode: String

    enum CodingKeys: String, CodingKey {
        case id = "task"         // Заменим id на task
        case title
        case description
        case colorCode = "colorCode"
    }
}
