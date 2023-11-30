import Foundation
import MapKit

struct Country: Decodable, Identifiable {
    var id = UUID()
    var names: Names
    var population: Int
    var area: Double
    var flag: Flag
    var coordinates: Coordinates
    
    enum CodingKeys: String, CodingKey {
        case names = "name"
        case population = "population"
        case area = "area"
        case flag = "flags"
        case coordinates = "latlng"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        names = try container.decode(Names.self, forKey: .names)
        population = try container.decode(Int.self, forKey: .population)
        area = try container.decode(Double.self, forKey: .area)
        flag = try container.decode(Flag.self, forKey: .flag)

        var coordinatesArray = try container.nestedUnkeyedContainer(forKey: .coordinates)
        let latitude = try coordinatesArray.decode(Double.self)
        let longitude = try coordinatesArray.decode(Double.self)
        coordinates = Coordinates(lat: latitude, lon: longitude)
    }
}

struct Coordinates: Decodable {
    let lat: Double
    let lon: Double
    
    var clLocationCordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
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
