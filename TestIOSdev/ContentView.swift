//
//  ContentView.swift
//  TestIOSdev
//
//  Created by Дмитрий Куприянов on 10.02.25.
//

import SwiftUI
import Foundation
import Network

struct ContentView: View {
    @State private var tasks: [LocalTask] = []
    @State private var searchText: String = ""
    @State private var isShowingScanner = false
    @State private var scannedCode: String?

    var filteredTasks: [LocalTask] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter { task in
                task.title.lowercased().contains(searchText.lowercased()) ||
                task.description.lowercased().contains(searchText.lowercased()) ||
                task.task.lowercased().contains(searchText.lowercased()) ||
                task.wageType.lowercased().contains(searchText.lowercased()) ||
                task.BusinessUnitKey.lowercased().contains(searchText.lowercased()) ||
                task.parentTaskID.lowercased().contains(searchText.lowercased()) ||
                (task.colorCode?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                
                List(filteredTasks) { task in
                    HStack {
                        if let colorCode = task.colorCode, !colorCode.isEmpty {
                            Color(hex: colorCode)
                                .frame(width: 20, height: 20)
                                .cornerRadius(4)
                        } else {
                            ZStack {
                                 RoundedRectangle(cornerRadius: 4)
                                     .stroke(Color.gray, lineWidth: 1)
                                     .frame(width: 20, height: 20)
                                
                                Rectangle()
                                    .frame(width: 20, height: 2)
                                    .foregroundColor(.red)
                                    .rotationEffect(.degrees(-45))
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(task.wageType)
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(task.BusinessUnitKey)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                .refreshable {
                    fetchTasks() // Pull-to-Refresh
                }
                .navigationBarItems(trailing:
                    Button(action: {
                        isShowingScanner = true
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                            .imageScale(.large)
                    }
                )
                .onChange(of: scannedCode) {
                    if let newValue = scannedCode {
                        searchText = newValue
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    QRCodeScannerView(scannedCode: $scannedCode)
                }
            }
            .navigationTitle("Task List")
            .onAppear {
                fetchTasks()
            }
        }
    }

    func fetchTasks() {
        isInternetAvailable { isConnected in
            if isConnected {
                // Загрузка данных из сети
                APIClient.shared.fetchToken { token in
                    if let token = token {
                        APIClient.shared.fetchTasks(token: token) { tasks in
                            DispatchQueue.main.async {
                                self.tasks = tasks?.map {
                                    LocalTask(
                                        task: $0.task,
                                        title: $0.title,
                                        description: $0.description,
                                        sort: $0.sort,
                                        wageType: $0.wageType,
                                        BusinessUnitKey: $0.BusinessUnitKey ?? "No Key",
                                        businessUnit: $0.businessUnit,
                                        parentTaskID: $0.parentTaskID,
                                        preplanningBoardQuickSelect: $0.preplanningBoardQuickSelect,
                                        colorCode: $0.colorCode,
                                        workingTime: $0.workingTime,
                                        isAvailableInTimeTrackingKioskMode: $0.isAvailableInTimeTrackingKioskMode
                                    )
                                } ?? []
                                self.saveTasksToLocal(self.tasks)
                            }
                        }
                    } else {
                        print("Didn't get token")
                    }
                }
            } else {
                // Загрузка данных из локального хранилища
                self.tasks = loadTasksFromLocal() ?? []

                if self.tasks.isEmpty {
                    print("No internet and no local data")
                }
            }
        }
    }

    func saveTasksToLocal(_ tasks: [LocalTask]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }

    func loadTasksFromLocal() -> [LocalTask]? {
        if let savedData = UserDefaults.standard.object(forKey: "tasks") as? Data {
            let decoder = JSONDecoder()
            if let loadedTasks = try? decoder.decode([LocalTask].self, from: savedData) {
                return loadedTasks
            }
        }
        return nil
    }

    func isInternetAvailable(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue.global())
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                completion(path.status == .satisfied)
            }
        }
    }
}

struct LocalTask: Identifiable, Codable {
    var id: String { task }
    var task: String
    var title: String
    var description: String
    var sort: String
    var wageType: String
    var BusinessUnitKey: String
    var businessUnit: String
    var parentTaskID: String
    var preplanningBoardQuickSelect: String?
    var colorCode: String?
    var workingTime: String?
    var isAvailableInTimeTrackingKioskMode: Bool
}

// Search bar
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        TextField("Search...", text: $text)
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    Spacer()
                }
            )
            .padding(.horizontal)
    }
}

// Extension for working with color
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        if hexSanitized.count == 6 {
            var rgb: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgb)
            let red = Double((rgb >> 16) & 0xFF) / 255.0
            let green = Double((rgb >> 8) & 0xFF) / 255.0
            let blue = Double(rgb & 0xFF) / 255.0
            self.init(red: red, green: green, blue: blue)
        } else {
            self.init(white: 0.5)
        }
    }
}

#Preview {
    ContentView()
}
