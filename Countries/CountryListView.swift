import Foundation
import SwiftUI

class CountryViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortedAscending = true
    @Published var sortCriterion: SortCriterion = .commonName
    
    @Published private var loadedCountries: [Country] = []
    var countries: [Country] {
        get {
            let sortedCountries = loadedCountries.sorted { firstCountry, secondCountry in
                switch sortCriterion {
                case .commonName:
                    return sortedAscending ? (firstCountry.names.common < secondCountry.names.common) : (firstCountry.names.common > secondCountry.names.common)
                case .area:
                    return sortedAscending ? (firstCountry.area < secondCountry.area) : (firstCountry.area > secondCountry.area)
                case .population:
                    return sortedAscending ? (firstCountry.population < secondCountry.population) : (firstCountry.population > secondCountry.population)
                case .density:
                    let firstDensity = Double(firstCountry.population) / firstCountry.area
                    let secondDensity = Double(secondCountry.population) / secondCountry.area
                    return sortedAscending ? (firstDensity < secondDensity) : (firstDensity > secondDensity)
                }
            }
            return sortedCountries
        }
    }
    
    private var apiService = ApiService()
    
    @MainActor
    func loadCountries(force: Bool = false) async throws {
        if loadedCountries.isEmpty || force {
            isLoading = true
            loadedCountries = []
            loadedCountries = try await apiService.fetchCountriesAsync()
            isLoading = false
        }
    }

    
    func toggleSorting() {
        sortedAscending.toggle()
    }
}


struct CountryListView: View {
    @ObservedObject var viewModel = CountryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                }
                
                List(viewModel.countries) { country in
                    HStack {
                        if let url = URL(string: country.flag.png) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .scaledToFit()
                            .frame(width: 50)
                            .padding([.trailing], 10)
                        }
                        VStack(alignment: .leading) {
                            Text(country.names.common)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Official Name: \(country.names.official)")
                            
                            Text("Population: \(country.population)")
                            Text("Area: \(formatDoubleValues(val: country.area, maximumFractionDigits: 2)) km²")
                            Text("Density: \(formatDoubleValues(val: Double(country.population) / country.area, maximumFractionDigits: 2)) ppl / km²")
                        }}
                    
                }.listStyle(.plain)
                    .onAppear {
                        Task {
                            do {
                                try await viewModel.loadCountries()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Countries")
                        .font(.title)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.loadCountries(force: true)
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Sort by name") {
                            viewModel.sortCriterion = .commonName
                        }
                        Button("Sort by population") {
                            viewModel.sortCriterion = .population
                        }
                        Button("Sort by area") {
                            viewModel.sortCriterion = .area
                        }
                        Button("Sort by density") {
                            viewModel.sortCriterion = .density
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.toggleSorting() }) {
                        let icon = viewModel.sortedAscending ? "arrow.up" : "arrow.down"
                        Image(systemName: icon)
                    }
                }
            }
        }
    }
}

