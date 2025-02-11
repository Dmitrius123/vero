//
//  ContentView.swift
//  TestIOSdev
//
//  Created by Дмитрий Куприянов on 10.02.25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var searchText: String = ""
    @State private var isShowingScanner = false
    @State private var scannedCode: String?

    var filteredTasks: [Task] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter { task in
                task.title.lowercased().contains(searchText.lowercased()) ||
                task.description.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                
                List(filteredTasks) { task in
                    HStack {
                        Color(hex: task.colorCode)
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)

                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
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
        APIClient.shared.fetchToken { token in
            if let token = token {
                APIClient.shared.fetchTasks(token: token) { tasks in
                    DispatchQueue.main.async {
                        self.tasks = tasks ?? []
                    }
                }
            } else {
                print("Token receipt error")
            }
        }
    }
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
