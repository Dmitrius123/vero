//
//  Task.swift
//  TestIOSdev
//
//  Created by Дмитрий Куприянов on 10.02.25.
//

import Foundation

struct Task: Identifiable, Decodable, Encodable {
    var id: String { task }
    var task: String
    var title: String
    var description: String
    var sort: String
    var wageType: String
    var BusinessUnitKey: String?
    var businessUnit: String
    var parentTaskID: String
    var preplanningBoardQuickSelect: String?
    var colorCode: String?
    var workingTime: String?
    var isAvailableInTimeTrackingKioskMode: Bool
    
    enum CodingKeys: String, CodingKey {
        case task
        case title
        case description
        case sort
        case wageType
        case BusinessUnitKey
        case businessUnit
        case parentTaskID
        case preplanningBoardQuickSelect
        case colorCode
        case workingTime
        case isAvailableInTimeTrackingKioskMode
    }
    
}
