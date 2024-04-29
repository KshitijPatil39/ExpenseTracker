//
//  MapView.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/30/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    let lat: CLLocationDegrees
    let long: CLLocationDegrees
    @State private var region: MKCoordinateRegion
    init(lat: CLLocationDegrees, long: CLLocationDegrees) {
            self.lat = lat
            self.long = long
            _region = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)))
        }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [Place(latitude: lat, longitude: long)]) {place  in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
        }
        .frame(width: 350, height: 250)
        .padding(.horizontal, 20)
    }
    
    struct Place: Identifiable {
        let id = UUID()
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(lat:40.740352, long: -74.001761)
    }
}
