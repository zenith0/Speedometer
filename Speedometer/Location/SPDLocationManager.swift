//
//  SPDLocationManager.swift
//  Speedometer
//
//  Created by Stefan Perndl on 04.12.18.
//  Copyright © 2018 zenith. All rights reserved.
//

import Foundation
import CoreLocation
import Swinject

protocol SPDLocationManagerDelegate: class {
    func locationManager(_ manager: SPDLocationManager, didUpdateLocations locations: [CLLocation])
}

protocol SPDLocationManagerAuthorizingDelegate: class {
    func locationManager(_ manager: SPDLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
}

protocol SPDLocationManager: class {
    var delegate: SPDLocationManagerDelegate? { get set }
    var authorizingDelegate: SPDLocationManagerAuthorizingDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

class SPDLocationManagerProxy: NSObject {
    weak var delegate: SPDLocationManagerDelegate?
    weak var authorizingDelegate: SPDLocationManagerAuthorizingDelegate?
    
    let locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
    }
}

extension SPDLocationManagerProxy: SPDLocationManager {
    var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    func requestWhenInUseAuthorization() {
        return locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        return locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        return locationManager.stopUpdatingLocation()
    }
}

extension SPDLocationManagerProxy: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(self, didUpdateLocations:locations)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizingDelegate?.locationManager(self, didChangeAuthorization: status)
    }

}

class SPDLocationManagerAssembly: Assembly {

    func assemble(container: Container) {
        container.register(SPDLocationManager.self, factory: { r in

            let locationManager  = CLLocationManager()
            return SPDLocationManagerProxy(locationManager: locationManager)
        }).inObjectScope(.weak)
    }
}
