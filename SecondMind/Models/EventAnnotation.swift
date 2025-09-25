//
//  EventAnnotation.swift
//  SecondMind
//
//  Created by Jorge Cortés on 25/9/25.
//

import MapKit

struct EventAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
