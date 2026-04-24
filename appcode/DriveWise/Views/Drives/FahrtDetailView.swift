//
//  FahrtDetailView.swift
//  DriveWise
//
//  Detailansicht für eine einzelne Fahrt
//

import SwiftUI
import MapKit

struct FahrtDetailView: View {
    enum RouteSource: Equatable {
        case recorded
        case appleDirections
        case straightFallback
        case unavailable
    }

    let drive: Drive
    @State private var recordedRouteCoordinates: [CLLocationCoordinate2D] = []
    @State private var routeSource: RouteSource = .unavailable
    private let routeStorageService = DriveRouteStorageService()

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppLayout.pageSpacing) {
                    // title
                    VStack(spacing: 2) {
                        Text("Fahrtdetails")
                            .appPageTitleStyle()
                    }
                    .padding(.top)
                    headerCard
                    scoreCard

                    if let start = drive.startCoordinate, let end = drive.endCoordinate {
                        VStack(alignment: .leading, spacing: 8) {
                            RouteMapView(
                                start: start,
                                end: end,
                                startTitle: drive.from,
                                endTitle: drive.to,
                                routeCoordinates: recordedRouteCoordinates,
                                errorEvents: drive.errorEvents,
                                routeSource: $routeSource
                            )
                                .frame(height: 220)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.accentFigma.opacity(0.9), lineWidth: 3)
                                )

                            if let routeHintText {
                                Text(routeHintText)
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .padding(.horizontal, AppLayout.horizontalPadding)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                        Rectangle()
                            .fill(Color.white.opacity(0.02))
                            .frame(height: 220)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.accentFigma.opacity(0.9), lineWidth: 3)
                            )
                                .overlay(Text("Kartenansicht").foregroundColor(.textSecondary))

                            Text("Hinweis: Keine Route verfügbar, da Start- oder Zielkoordinate fehlt.")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, AppLayout.horizontalPadding)
                    }

                    errorOverviewCard
                    metricsSection

                    HStack {
                        Spacer()
                        DrivingCriteriaInfoView()
                        Spacer()
                    }
                    .padding(.vertical, 12)

                    Spacer(minLength: 60)
                }
            }
            .onAppear {
                recordedRouteCoordinates = routeStorageService.loadRoute(for: drive.id)
                routeSource = .unavailable
            }
            .onChange(of: drive.id) { _, newDriveId in
                recordedRouteCoordinates = routeStorageService.loadRoute(for: newDriveId)
                routeSource = .unavailable
            }
        }
    }

    private var routeHintText: String? {
        switch routeSource {
        case .recorded:
            return nil
        case .appleDirections:
            return "Hinweis: Angezeigte Route ist eine berechnete Apple-Karten-Route (wenn vorhanden über Event-Zwischenpunkte)."
        case .straightFallback:
            return "Hinweis: Route nicht verfügbar, daher wird eine direkte Verbindung angezeigt."
        case .unavailable:
            return "Hinweis: Keine Routeninformationen konnten geladen werden."
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppDateTimeFormatter.fullDateDE(drive.startDate))
                .font(.headline)
                .foregroundColor(.textPrimary)

            HStack(spacing: 12) {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.textPrimary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(drive.from)
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.textPrimary)
                                    Text(AppDateTimeFormatter.shortTime(drive.startDate))
                                        .font(.caption2)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        Spacer()
                    }

                    Divider()
                        .background(Color.textSecondary.opacity(0.2))
                        .padding(.vertical, 8)

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "flag.checkered")
                                    .foregroundColor(.textPrimary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(drive.to)
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.textPrimary)
                                    Text(AppDateTimeFormatter.shortTime(drive.endDate))
                                        .font(.caption2)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        Spacer()
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "car.fill")
                            .foregroundColor(.blue)
                            .frame(width: 16)
                        Text(UnitFormatter.distance(drive.distanceKm, unitSystem: .metric, fractionDigits: 1))
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                            .frame(width: 16)
                        Text(AppDateTimeFormatter.durationClockWithSuffix(drive.endDate.timeIntervalSince(drive.startDate)))
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 12)
        .padding(.horizontal, AppLayout.horizontalPadding)
    }

    private var scoreCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fahrscore")
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                    Text("\(drive.score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(scoreColor.opacity(0.2))
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: CGFloat(drive.score) / 120.0)
                        .stroke(scoreColor, lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Text("\(drive.score)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(scoreColor)
                }
            }

            Text(scoreDescription)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 12)
        .padding(.horizontal, AppLayout.horizontalPadding)
    }

    private var errorOverviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fehlerübersicht")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            HStack(alignment: .top, spacing: 12) {
                let breakdown = (
                    brake: drive.hardBrakeCount + drive.veryHardBrakeCount,
                    steer: drive.sharpTurnCount + drive.verySharpTurnCount,
                    accel: drive.hardAccelCount + drive.veryHardAccelCount
                )

                detailMetric(icon: "exclamationmark.circle", title: "Allg.", value: "\(drive.errorCount)")
                detailMetric(icon: "arrow.down.to.line.alt", title: "Bremsen", value: "\(breakdown.brake)")
                detailMetric(icon: "steeringwheel", title: "Lenken", value: "\(breakdown.steer)")
                detailMetric(icon: "speedometer", title: "Beschl.", value: "\(breakdown.accel)")
            }
        }
        .padding(20)
        .appSectionCardStyle(cornerRadius: 12)
        .padding(.horizontal, AppLayout.horizontalPadding)
    }

    private var metricsSection: some View {
        let durationMinutes = Int(drive.endDate.timeIntervalSince(drive.startDate) / 60)
        let duration = durationMinutes < 60 ?
            "\(durationMinutes) min" :
            "\(durationMinutes / 60)h \(durationMinutes % 60)min"
        let maxGAccel = drive.maxAccelMS2 / 9.81
        let maxGBrake = drive.maxBrakeMS2 / 9.81
        let maxGLateral = drive.maxLateralAccelMS2 / 9.81

        return VStack(spacing: 12) {
            metricRow(icon: "gauge", title: "Durchschnittsgeschwindigkeit", value: UnitFormatter.speed(drive.avgSpeedKmh, unitSystem: .metric, fractionDigits: 0))
            metricRow(icon: "hare.fill", title: "Höchstgeschwindigkeit", value: UnitFormatter.speed(drive.maxSpeedKmh, unitSystem: .metric, fractionDigits: 0))
            metricRow(icon: "arrow.up.right", title: "Max. Beschleunigung", value: String(format: "%.2f G", maxGAccel))
            metricRow(icon: "arrow.down.right", title: "Max. Bremsung", value: String(format: "%.2f G", maxGBrake))
            metricRow(icon: "arrow.2.circlepath.circle", title: "Max. Kurvenverhalten", value: String(format: "%.2f G", maxGLateral))
            metricRow(icon: "clock.fill", title: "Dauer", value: duration)
            metricRow(icon: "car", title: "Distanz", value: UnitFormatter.distance(drive.distanceKm, unitSystem: .metric, fractionDigits: 1))
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
    }

    private func detailMetric(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.textPrimary)
                .frame(height: 32)
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .frame(height: 16)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
                .frame(height: 24)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func metricRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 44, height: 44)
                .background(Color(.sRGB, red: 20/255, green: 70/255, blue: 110/255, opacity: 1))
                .cornerRadius(10)
                .foregroundColor(.white)
            VStack(alignment: .leading) {
                Text(title).font(.subheadline).foregroundColor(.textSecondary)
                Text(value).bold().foregroundColor(.textPrimary)
            }
            Spacer()
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 12)
    }

    private var scoreColor: Color {
        if drive.score >= 100 {
            return .green
        } else if drive.score >= 80 {
            return .yellow
        } else if drive.score >= 60 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var scoreDescription: String {
        if drive.score >= 100 {
            return "Ausgezeichnet! Du fährst sehr sicher."
        } else if drive.score >= 80 {
            return "Gut! Ein paar Fehler, aber insgesamt sichereres Fahren."
        } else if drive.score >= 60 {
            return "Akzeptabel. Achte auf dein Fahrverhalten."
        } else {
            return "Verbesserung nötig. Sei defensiver und ruhiger."
        }
    }

}

#Preview {
    FahrtDetailView(
        drive: Drive(
            id: UUID(),
            startDate: Date().addingTimeInterval(-400),
            endDate: Date(),
            from: "Malsch",
            to: "Durmersheim",
            distanceKm: 4.7,
            avgSpeedKmh: 55,
            maxSpeedKmh: 130,
            maxAccelMS2: 2.7,
            maxBrakeMS2: 3.5,
            maxLateralAccelMS2: 3.9,
            hardBrakeCount: 1,
            hardAccelCount: 1,
            sharpTurnCount: 0,
            errorCount: 2,
            score: 93,
            startLatitude: 48.8836,
            startLongitude: 8.3341,
            endLatitude: 48.9345,
            endLongitude: 8.2832,
            errorEvents: []
        )
    )
}

private struct RouteMapView: UIViewRepresentable {
    let start: CLLocationCoordinate2D
    let end: CLLocationCoordinate2D
    let startTitle: String
    let endTitle: String
    let routeCoordinates: [CLLocationCoordinate2D]
    let errorEvents: [DriveErrorEvent]
    @Binding var routeSource: FahrtDetailView.RouteSource

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.showsCompass = false
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        guard context.coordinator.shouldRedraw(
            start: start,
            end: end,
            routeCoordinates: routeCoordinates,
            errorEvents: errorEvents
        ) else {
            return
        }

        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)

        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = start
        startAnnotation.title = startTitle

        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = end
        endAnnotation.title = endTitle

        var annotations: [MKAnnotation] = [startAnnotation, endAnnotation]
        let eventAnnotations = errorEvents.compactMap { event -> DriveErrorAnnotation? in
            guard let latitude = event.latitude, let longitude = event.longitude else { return nil }
            return DriveErrorAnnotation(event: event, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        annotations.append(contentsOf: eventAnnotations)

        mapView.addAnnotations(annotations)

        context.coordinator.updateRoute(
            mapView: mapView,
            start: start,
            end: end,
            routeCoordinates: routeCoordinates,
            errorEvents: errorEvents,
            routeSource: $routeSource
        )
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        private var currentDirections: MKDirections?
        private var lastRenderSignature: String?

        func shouldRedraw(
            start: CLLocationCoordinate2D,
            end: CLLocationCoordinate2D,
            routeCoordinates: [CLLocationCoordinate2D],
            errorEvents: [DriveErrorEvent]
        ) -> Bool {
            let signature = renderSignature(
                start: start,
                end: end,
                routeCoordinates: routeCoordinates,
                errorEvents: errorEvents
            )

            if lastRenderSignature == signature {
                return false
            }

            lastRenderSignature = signature
            return true
        }

        private func renderSignature(
            start: CLLocationCoordinate2D,
            end: CLLocationCoordinate2D,
            routeCoordinates: [CLLocationCoordinate2D],
            errorEvents: [DriveErrorEvent]
        ) -> String {
            let startPart = String(format: "%.5f,%.5f", start.latitude, start.longitude)
            let endPart = String(format: "%.5f,%.5f", end.latitude, end.longitude)

            let routeEdgePart: String = {
                guard let first = routeCoordinates.first, let last = routeCoordinates.last else {
                    return "none"
                }
                return String(
                    format: "%.5f,%.5f|%.5f,%.5f|%d",
                    first.latitude,
                    first.longitude,
                    last.latitude,
                    last.longitude,
                    routeCoordinates.count
                )
            }()

            let eventPart = errorEvents
                .sorted { $0.id.uuidString < $1.id.uuidString }
                .map { event in
                    let lat = event.latitude ?? 0
                    let lon = event.longitude ?? 0
                    let coordinatePart = String(format: "%.5f,%.5f", lat, lon)
                    return "\(event.id.uuidString):\(event.type.rawValue):\(event.severity.rawValue):\(coordinatePart)"
                }
                .joined(separator: ";")

            return [startPart, endPart, routeEdgePart, eventPart].joined(separator: "#")
        }

        func updateRoute(
            mapView: MKMapView,
            start: CLLocationCoordinate2D,
            end: CLLocationCoordinate2D,
            routeCoordinates: [CLLocationCoordinate2D],
            errorEvents: [DriveErrorEvent],
            routeSource: Binding<FahrtDetailView.RouteSource>
        ) {
            currentDirections?.cancel()

            if routeCoordinates.count >= 2 {
                DispatchQueue.main.async {
                    routeSource.wrappedValue = .recorded
                }
                var coordinates = routeCoordinates
                if coordinates.first?.latitude != start.latitude || coordinates.first?.longitude != start.longitude {
                    coordinates.insert(start, at: 0)
                }
                if coordinates.last?.latitude != end.latitude || coordinates.last?.longitude != end.longitude {
                    coordinates.append(end)
                }

                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                mapView.addOverlay(polyline)
                let padding = UIEdgeInsets(top: 28, left: 28, bottom: 28, right: 28)
                mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: padding, animated: false)
                return
            }

            let waypointCoordinates = sanitizedWaypointCoordinates(
                from: errorEvents,
                start: start,
                end: end
            )
            let routeNodes = [start] + waypointCoordinates + [end]

            calculateSegmentedRoute(nodes: routeNodes) { [weak mapView] polylines in
                guard let mapView else { return }
                mapView.removeOverlays(mapView.overlays)

                if let polylines, !polylines.isEmpty {
                    DispatchQueue.main.async {
                        routeSource.wrappedValue = .appleDirections
                    }
                    polylines.forEach { mapView.addOverlay($0) }

                    let fullRect = polylines
                        .map { $0.boundingMapRect }
                        .reduce(MKMapRect.null) { $0.union($1) }
                    let padding = UIEdgeInsets(top: 28, left: 28, bottom: 28, right: 28)
                    mapView.setVisibleMapRect(fullRect, edgePadding: padding, animated: false)
                } else {
                    DispatchQueue.main.async {
                        routeSource.wrappedValue = .straightFallback
                    }
                    let line = MKPolyline(coordinates: [start, end], count: 2)
                    mapView.addOverlay(line)
                    let padding = UIEdgeInsets(top: 28, left: 28, bottom: 28, right: 28)
                    mapView.setVisibleMapRect(line.boundingMapRect, edgePadding: padding, animated: false)
                }
            }
        }

        private func calculateSegmentedRoute(
            nodes: [CLLocationCoordinate2D],
            completion: @escaping ([MKPolyline]?) -> Void
        ) {
            guard nodes.count >= 2 else {
                completion(nil)
                return
            }

            var segmentPolylines: [MKPolyline] = []

            func requestSegment(at index: Int) {
                if index >= nodes.count - 1 {
                    completion(segmentPolylines)
                    return
                }

                let request = MKDirections.Request()
                request.source = MKMapItem(location: CLLocation(latitude: nodes[index].latitude, longitude: nodes[index].longitude), address: nil)
                request.destination = MKMapItem(location: CLLocation(latitude: nodes[index + 1].latitude, longitude: nodes[index + 1].longitude), address: nil)
                request.transportType = .automobile

                let directions = MKDirections(request: request)
                currentDirections = directions

                directions.calculate { response, _ in
                    guard let route = response?.routes.first else {
                        completion(nil)
                        return
                    }

                    segmentPolylines.append(route.polyline)
                    requestSegment(at: index + 1)
                }
            }

            requestSegment(at: 0)
        }

        private func sanitizedWaypointCoordinates(
            from errorEvents: [DriveErrorEvent],
            start: CLLocationCoordinate2D,
            end: CLLocationCoordinate2D
        ) -> [CLLocationCoordinate2D] {
            let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
            let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)

            let ordered = errorEvents
                .sorted { $0.timestamp < $1.timestamp }
                .compactMap { event -> CLLocationCoordinate2D? in
                    guard let lat = event.latitude, let lon = event.longitude else { return nil }
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    return CLLocationCoordinate2DIsValid(coordinate) ? coordinate : nil
                }

            var filtered: [CLLocationCoordinate2D] = []
            var lastAcceptedLocation: CLLocation?

            for coordinate in ordered {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

                if location.distance(from: startLocation) < 80 || location.distance(from: endLocation) < 80 {
                    continue
                }

                if let lastAcceptedLocation, location.distance(from: lastAcceptedLocation) < 40 {
                    continue
                }

                filtered.append(coordinate)
                lastAcceptedLocation = location

                if filtered.count >= 6 {
                    break
                }
            }

            return filtered
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let line = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolylineRenderer(polyline: line)
            renderer.strokeColor = UIColor(Color.accentFigma)
            renderer.lineWidth = 4
            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            if let eventAnnotation = annotation as? DriveErrorAnnotation {
                let identifier = "ErrorEventAnnotation"
                let view = (mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView)
                    ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.annotation = annotation
                view.canShowCallout = true

                switch eventAnnotation.event.type {
                case .brake:
                    view.markerTintColor = UIColor.systemRed
                    view.glyphImage = UIImage(systemName: "arrow.down.to.line.alt")
                case .acceleration:
                    view.markerTintColor = UIColor.systemBlue
                    view.glyphImage = UIImage(systemName: "speedometer")
                case .turn:
                    view.markerTintColor = UIColor.systemOrange
                    view.glyphImage = UIImage(systemName: "steeringwheel")
                }

                return view
            }

            let identifier = "StartEndAnnotation"
            let view = (mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView)
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            view.canShowCallout = true
            view.markerTintColor = UIColor(Color.accentFigma)
            return view
        }
    }
}

private final class DriveErrorAnnotation: NSObject, MKAnnotation {
    let event: DriveErrorEvent
    let coordinate: CLLocationCoordinate2D

    init(event: DriveErrorEvent, coordinate: CLLocationCoordinate2D) {
        self.event = event
        self.coordinate = coordinate
        super.init()
    }

    var title: String? {
        switch event.type {
        case .brake:
            return event.severity == .veryHard ? "Sehr starke Bremsung" : "Starke Bremsung"
        case .acceleration:
            return event.severity == .veryHard ? "Sehr starke Beschleunigung" : "Starke Beschleunigung"
        case .turn:
            return event.severity == .veryHard ? "Sehr starkes Kurvenverhalten" : "Starkes Kurvenverhalten"
        }
    }

    var subtitle: String? {
        "\(Int(event.speedKmh)) km/h • \(String(format: "%.2f G", event.accelerationG))"
    }
}
