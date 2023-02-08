//
//  PermissionCompatible.swift
//  GeSwift
//
//  Created by my on 2023/1/14.
//  Copyright © 2023 my. All rights reserved.
//

import Contacts
import CoreLocation
import EventKit
import Foundation
import UIKit
import UserNotifications

public enum PermissionStatus {
    case unknown
    case authorized
    case denied
    case notDetermined
}

public protocol PermissionStatusCompatible {
    var permissionStatus: PermissionStatus { get }
}

//extension CLAuthorizationStatus: PermissionStatusCompatible {
//    var permissionStatus: PermissionStatus {
//        switch self {
//        case .restricted, .denied: return .denied
//        case .authorized, .authorizedAlways, .authorizedWhenInUse: return .authorized
//        case .notDetermined: return .notDetermined
//        @unknown default: return .unknown
//        }
//    }
//}

//extension CNAuthorizationStatus: PermissionStatusCompatible {
//    var permissionStatus: PermissionStatus {
//        switch self {
//        case .authorized: return .authorized
//        case .notDetermined: return .notDetermined
//        case .denied, .restricted: return .denied
//        @unknown default: return .unknown
//        }
//    }
//}

//extension EKAuthorizationStatus: PermissionStatusCompatible {
//    var permissionStatus: PermissionStatus {
//        switch self {
//        case .restricted, .denied: return .denied
//        case .authorized: return .authorized
//        case .notDetermined: return .notDetermined
//        @unknown default: return .unknown
//        }
//    }
//}



public protocol PermissionCompatiable {
    var infoDescription: String? { get }

    var permissionStatus: PermissionStatus { get }

    func requestAuthorizionWithCallback(_ callback: @escaping (Bool, PermissionStatus) -> Void)

    func permissionStatusWithCallback(_ callback: @escaping (PermissionStatus) -> Void)
}

public extension PermissionCompatiable {
    func permissionStatusWithCallback(_ callback: @escaping (PermissionStatus) -> Void) {
        callback(permissionStatus)
    }
}

public struct Permissions {
    public let permission: PermissionCompatiable
    public init(permission: PermissionCompatiable) {
        self.permission = permission
    }
}

extension Permissions: PermissionCompatiable {
    public var infoDescription: String? {
        permission.infoDescription
    }

    public var permissionStatus: PermissionStatus {
        permission.permissionStatus
    }

    public func permissionStatusWithCallback(_ callback: @escaping (PermissionStatus) -> Void) {
        permission.permissionStatusWithCallback(callback)
    }

    public func requestAuthorizionWithCallback(_ callback: @escaping (Bool, PermissionStatus) -> Void) {
        permission.requestAuthorizionWithCallback(callback)
    }

    public func requestAuthorizionWithCallback(_ from: UIViewController? = nil,
                                               redirectToSettingsIfDenied redirectToSettings: Bool,
                                               callback: @escaping (PermissionStatus) -> Void)
    {
        let _callBack: (Bool, URL?, PermissionStatus) -> Void = { isNotDetermined, URL, status in
            DispatchQueue.main.async {
                if status == .denied, redirectToSettings, !isNotDetermined {
                    self.showAlertAndRedirectToURL(URL, from: from)
                }
                callback(status)
            }
        }

        let setttingURLCallback: (Bool, PermissionStatus) -> Void = {
            _callBack($0, URL(string: UIApplication.openSettingsURLString), $1)
        }

        requestAuthorizionWithCallback(setttingURLCallback)
    }

    private func showAlertAndRedirectToURL(_ url: URL?, from viewController: UIViewController?) {
        let alertController = UIAlertController(title: "", message: infoDescription, preferredStyle: .alert)
        alertController.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .destructive))
        alertController.addAction(.init(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { _ in
            if let _url = url, UIApplication.shared.canOpenURL(_url) {
                UIApplication.shared.open(_url)
            }
        }))

        var _viewController = viewController
        if _viewController == nil {
            _viewController = UIApplication.shared.delegate?.window??.rootViewController
        }
        _viewController?.present(alertController, animated: true)
    }
}

//
// extension Permissions {
//    func locationPermission() -> PermissionStatus {
//        if #available(iOS 14.0, *) {
//            return Permissions.store.locationManager.authorizationStatus.permissionStatus
//        } else {
//            return CLLocationManager.authorizationStatus().permissionStatus
//        }
//    }
//
//    func contactsPersmission() -> PermissionStatus {
//        CNContactStore.authorizationStatus(for: .contacts).permissionStatus
//    }
//
//    func calendarPermission(_ type: EKEntityType) -> PermissionStatus {
//        EKEventStore.authorizationStatus(for: type).permissionStatus
//    }
// }
//
// extension Permissions {
//
//    func requestLocation(_ completion: @escaping (Bool, PermissionStatus) -> Void) {
//        let status = locationPermission()
//        switch status {
//        case .notDetermined:
//            Permissions.store.locationAuthorizationCallback = {
//                completion(true, $0)
//            }
//            let locationManager = Permissions.store.locationManager
//            locationManager.requestWhenInUseAuthorization()
//            locationManager.requestAlwaysAuthorization()
//        default:
//            completion(false, status)
//        }
//    }
//
//
//    func requestContacts(_ completion: @escaping (Bool, PermissionStatus) -> Void) {
//        let status = contactsPersmission()
//        switch contactsPersmission() {
//        case .notDetermined:
//            CNContactStore().requestAccess(for: .contacts, completionHandler: { _, _ in
//                completion(true, self.contactsPersmission())
//            })
//        default:
//            completion(false, status)
//        }
//    }
//
//    func requestCalendar(_ type: EKEntityType, completion: @escaping (Bool, PermissionStatus) -> Void) {
//        let status = calendarPermission(type)
//        switch status {
//        case .notDetermined:
//            Permissions.store.eventStore.requestAccess(to: type, completion: { _, _ in
//                completion(true, self.calendarPermission(type))
//            })
//        default:
//            completion(false, status)
//        }
//    }
// }