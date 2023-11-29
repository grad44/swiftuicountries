import Foundation

struct Country: Decodable, Identifiable {
    var id = UUID()
    var names: Names
    var population: Int
    var area: Double
    var flag: Flag
    
    enum CodingKeys: String, CodingKey {
        case names = "name"
        case population = "population" // Replace with actual JSON field name
        case area = "area" // Replace with actual JSON field name
        case flag = "flags" // Replace with actual JSON field name
    }
}

struct Names: Decodable {
    var common: String
    var official: String
}

struct Flag: Decodable {
    var png: String
}

enum SortCriterion {
    case commonName
    case population
    case area
    case density
}

class ApiService {
    func fetchCountriesAsync() async throws -> [Country] {
        let urlString = "https://restcountries.com/v3.1/independent?status=true"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "ApiServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.addValue("identity", forHTTPHeaderField: "Accept-Encoding")
        
        let (data, _) = try await URLSession.shared.data(for: request)

        let decodedData = try JSONDecoder().decode([Country].self, from: data)
        return decodedData
    }
}
