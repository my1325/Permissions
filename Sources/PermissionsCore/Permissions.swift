//
//  PermissionCompatible.swift
//  GeSwift
//
//  Created by my on 2023/1/14.
//  Copyright © 2023 my. All rights reserved.
//

import UIKit

public enum PermissionStatus {
    case unknown
    case authorized
    case denied
    case notDetermined
}

public protocol PermissionStatusCompatible {
    var permissionStatus: PermissionStatus { get }
}

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
                                               title: String = "Permission Denied",
                                               cancelTitle: String = "Cancel",
                                               setttingTitle: String = "Settings",
                                               redirectToSettingsIfDenied redirectToSettings: Bool,
                                               redirectToSettingsMessage message: String?,
                                               callback: @escaping (PermissionStatus) -> Void)
    {
        let _callBack: (Bool, URL?, PermissionStatus) -> Void = { isNotDetermined, URL, status in
            DispatchQueue.main.async {
                if status == .denied, redirectToSettings, !isNotDetermined {
                    self.showAlertAndRedirectToURL(URL,
                                                   title: title,
                                                   cancelTitle: cancelTitle,
                                                   setttingTitle: setttingTitle,
                                                   message: message ?? infoDescription,
                                                   from: from)
                }
                callback(status)
            }
        }

        let setttingURLCallback: (Bool, PermissionStatus) -> Void = {
            _callBack($0, URL(string: UIApplication.openSettingsURLString), $1)
        }

        requestAuthorizionWithCallback(setttingURLCallback)
    }

    private func showAlertAndRedirectToURL(_ url: URL?,
                                           title: String,
                                           cancelTitle: String,
                                           setttingTitle: String,
                                           message: String?,
                                           from viewController: UIViewController?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: cancelTitle, style: .destructive))
        alertController.addAction(.init(title: setttingTitle, style: .default, handler: { _ in
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
