import Foundation

struct Message: Decodable {
    let device: Device
    
    enum CodingKeys: String, CodingKey {
        case device = "record"
    }
}

struct Device: Decodable, Identifiable {
    let name: String
    let batteryLevel: Double
    
    var id: String {
        name
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "device_name"
        case batteryLevel = "battery_level"
    }
    
    var icon: String {
        switch name {
        case "iPad Pro":
            return "ipad"
        case "Apple Watch":
            return "applewatch"
        case "Air Pods":
            return "airpods"
        default:
            return "questionmark"
        }
    }
}
