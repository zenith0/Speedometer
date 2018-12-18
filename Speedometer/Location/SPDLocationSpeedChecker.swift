//
//  SPDLocationSpeedChecker.swift
//  Speedometer
//
//  Created by Stefan Perndl on 04.12.18.
//  Copyright © 2018 zenith. All rights reserved.
//

import Foundation
import CoreLocation
import Swinject

protocol SPDLocationSpeedCheckerDelegate: class {
    func exceedingMaximumSpeedChanged(for speedCheck: SPDLocationSpeedChecker)
}

protocol SPDLocationSpeedChecker: class {
    var delegate: SPDLocationSpeedCheckerDelegate? { get set }

    var maximumSpeed: CLLocationSpeed? { get set }
    var isExceedingMaximumSpeed: Bool { get }
}

class SPDDefaultLocationSpeedChecker {
    weak var delegate: SPDLocationSpeedCheckerDelegate?
    var maximumSpeed: CLLocationSpeed? {
        didSet{
            checkIfSpeedExceeds()
        }
    }
    var isExceedingMaximumSpeed = false {
        didSet {
            delegate?.exceedingMaximumSpeedChanged(for: self)
        }
    }

    var lastLocation: CLLocation?

    let locationProvider: SPDLocationProvider

    init(locationProvider: SPDLocationProvider) {
        self.locationProvider = locationProvider
        locationProvider.add(self)
    }
}

private extension SPDDefaultLocationSpeedChecker {
    func checkIfSpeedExceeds() {
        if let maximumSpeed = maximumSpeed, let location = lastLocation {
            isExceedingMaximumSpeed = location.speed > maximumSpeed
        } else {
            isExceedingMaximumSpeed = false
        }
    }
}

extension SPDDefaultLocationSpeedChecker: SPDLocationSpeedChecker {

}

extension SPDDefaultLocationSpeedChecker: SPDLocationConsumer {
    func consumeLocation(_ location: CLLocation) {
        lastLocation = location
    }
}

class SPDLocationSpeedCheckerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SPDLocationSpeedChecker.self, factory: {r in
            let locationProvider = r.resolve(SPDLocationProvider.self)!
            return SPDDefaultLocationSpeedChecker(locationProvider: locationProvider)
        }).inObjectScope(.weak)
    }
}
