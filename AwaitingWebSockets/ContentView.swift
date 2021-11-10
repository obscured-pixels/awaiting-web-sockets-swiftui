import SwiftUI

struct ContentView: View {
    @State
    private var devices: [Device] = [
        Device(name: "iPad Pro",
               batteryLevel: 100),
        Device(name: "Apple Watch",
               batteryLevel: 100),
        Device(name: "Air Pods",
               batteryLevel: 100)
    ]
    private let stream = WebSocketStream(url: "wss://stream.overseed.io:443/v1/generators/org/68fb8641-e958-4c8a-84e0-bd24b199a2e7/generator/5f47628e-d92c-449b-8274-b690d2135204/stream/-1/?stream_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MzYwNzIwNDIsImlkIjoiM2ZmNGFiNzctMTc0Zi00ZGYzLWIyNzgtZmYyMGUzYzM3MDVhIn0.yhxB50P-61y8hDosif8pYQEle7QBf-ZwLOEJwXYO4kc")
    var body: some View {
        NavigationView {
            List {
                ForEach(devices) { device in
                    HStack(spacing: 0) {
                        Image(systemName: device.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(device.name)
                                .font(.title3)
                                .fontWeight(.bold)
                            ProgressView.init(value: device.batteryLevel/100)
                                .padding(.top, 10)
                                .animation(.default, value: device.batteryLevel/100)
                        }
                        .padding(.leading, 20)
                    }
                    .padding()
                }
            }
            .listStyle(.insetGrouped)
            .task {
                do {
                    for try await message in stream {
                        let updateDevice = try message.device()
                        devices = devices.map({ device in
                            device.id == updateDevice.id ? updateDevice : device
                        })
                    }
                } catch {
                    debugPrint("Oops something didn't go right")
                }
            }
            .navigationTitle("My Devices")
        }
    }
}

enum WebSocketError: Error {
    case invalidFormat
}

extension URLSessionWebSocketTask.Message {
    func device() throws -> Device {
        switch self {
        case .string(let json):
            let decoder = JSONDecoder()
            guard let data = json.data(using: .utf8) else {
                throw WebSocketError.invalidFormat
            }
            let message = try decoder.decode(Message.self, from: data)
            return message.device
        case .data:
            throw WebSocketError.invalidFormat
        @unknown default:
            throw WebSocketError.invalidFormat
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
