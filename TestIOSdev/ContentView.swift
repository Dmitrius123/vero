//
//  ContentView.swift
//  TestIOSdev
//
//  Created by Дмитрий Куприянов on 10.02.25.
//

import SwiftUI
import Foundation


extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var token: String = "Fetching Token..."
    
    var body: some View {
        VStack {
            Text(token)
                .padding()
            
            List(tasks) { task in
                HStack {
                    Text(task.title)
                    Spacer()
                    Text(task.description)
                    Rectangle()
                        .fill(Color(hex: task.colorCode))
                        .frame(width: 20, height: 20)
                }
            }
            .onAppear {
                APIClient.shared.fetchToken { fetchedToken in
                    DispatchQueue.main.async {
                        if let fetchedToken = fetchedToken {
                            token = "Access Token: \(fetchedToken)"
                            print("Полученный access_token:", fetchedToken)
                            // Теперь загружаем задачи
                            APIClient.shared.fetchTasks(token: fetchedToken) { tasks in
                                if let tasks = tasks {
                                    self.tasks = tasks
                                } else {
                                    token = "Ошибка получения задач"
                                    print("Ошибка получения задач")
                                }
                            }
                        } else {
                            token = "Ошибка получения токена"
                            print("Ошибка получения токена")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
