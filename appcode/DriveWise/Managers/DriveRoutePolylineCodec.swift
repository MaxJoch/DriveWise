import Foundation
import CoreLocation

final class DriveRoutePolylineCodec {
    private let scale: Double = 1e5

    func encode(_ coordinates: [CLLocationCoordinate2D]) -> String {
        guard !coordinates.isEmpty else { return "" }

        var result = ""
        var previousLat = 0
        var previousLon = 0

        for coordinate in coordinates {
            let latitude = Int((coordinate.latitude * scale).rounded())
            let longitude = Int((coordinate.longitude * scale).rounded())

            appendEncoded(latitude - previousLat, to: &result)
            appendEncoded(longitude - previousLon, to: &result)

            previousLat = latitude
            previousLon = longitude
        }

        return result
    }

    func decode(_ encoded: String) -> [CLLocationCoordinate2D] {
        guard !encoded.isEmpty else { return [] }

        var coordinates: [CLLocationCoordinate2D] = []
        var lat = 0
        var lon = 0
        var index = encoded.startIndex

        while index < encoded.endIndex {
            guard let latDelta = readEncodedValue(from: encoded, index: &index),
                  let lonDelta = readEncodedValue(from: encoded, index: &index) else {
                return coordinates
            }

            lat += latDelta
            lon += lonDelta

            let coordinate = CLLocationCoordinate2D(
                latitude: Double(lat) / scale,
                longitude: Double(lon) / scale
            )

            if CLLocationCoordinate2DIsValid(coordinate) {
                coordinates.append(coordinate)
            }
        }

        return coordinates
    }

    private func appendEncoded(_ value: Int, to output: inout String) {
        var adjusted = value << 1
        if value < 0 {
            adjusted = ~adjusted
        }

        while adjusted >= 0x20 {
            let chunk = (0x20 | (adjusted & 0x1f)) + 63
            if let scalar = UnicodeScalar(chunk) {
                output.append(Character(scalar))
            }
            adjusted >>= 5
        }

        let finalChunk = adjusted + 63
        if let scalar = UnicodeScalar(finalChunk) {
            output.append(Character(scalar))
        }
    }

    private func readEncodedValue(from encoded: String, index: inout String.Index) -> Int? {
        var result = 0
        var shift = 0

        while index < encoded.endIndex {
            let scalarValue = Int(encoded[index].unicodeScalars.first?.value ?? 0)
            index = encoded.index(after: index)

            let byte = scalarValue - 63
            if byte < 0 {
                return nil
            }

            result |= (byte & 0x1f) << shift
            shift += 5

            if byte < 0x20 {
                let delta = (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
                return delta
            }
        }

        return nil
    }
}
