//
//  PermissionAlertController.swift
//  GeSwift
//
//  Created by my on 2023/1/14.
//  Copyright © 2023 my. All rights reserved.
//

import UIKit

open class PermissionAlertController: UIViewController {
    private let iphone_width = UIScreen.main.bounds.width
    private let iphone_height = UIScreen.main.bounds.height
    
    private lazy var contentCenterY = NSLayoutConstraint(item: self.contentView, attribute: .centerY, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
    private lazy var contentLeft = NSLayoutConstraint(item: self.contentView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 30)
    private lazy var contentRight = NSLayoutConstraint(item: self.contentView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: -30)
    
    open lazy var heightConstraint = NSLayoutConstraint(item: self.tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.height)
    private lazy var dismissButton: UIButton = {
        $0.frame = self.view.bounds
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview($0)
        return $0
    }(UIButton(type: .custom))
    
    open lazy var contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = configuration.attribute?.value(for: .cornerRadius) ?? 16
        $0.backgroundColor = configuration.attribute?.value(for: .backgroundColor) ?? UIColor.white
        $0.clipsToBounds = true
        self.view.addSubview($0)
        return $0
    }(UIView())
    
    open lazy var tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.register(PermissionAlertCell.self, forCellReuseIdentifier: "PermissionAlertCell")
        $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        self.contentView.addSubview($0)
        let top = NSLayoutConstraint(item: $0, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: $0, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: $0, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: $0, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1, constant: 0)
        self.contentView.addConstraints([top, left, bottom, right])
        return $0
    }(UITableView(frame: .zero, style: .plain))
    
    private var dataSource: [Permissions] = []
    public let configuration: PermissionAlertConfiguration
    public let permissionList: [Permissions]
    public init(permissionList: [Permissions], configuration: PermissionAlertConfiguration = .default) {
        self.permissionList = permissionList
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .custom
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var isShowing: Bool = false
    private var isPrepared: Bool = false
    private var isViewAppeard: Bool = false
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.addConstraints([contentLeft, contentRight, contentCenterY])
        contentView.transform = CGAffineTransform(translationX: 0, y: -iphone_height)
        tableView.backgroundColor = .clear
        tableView.addConstraint(heightConstraint)
        dismissButton.addTarget(self, action: #selector(touchDismissAction), for: .touchUpInside)
        view.sendSubviewToBack(dismissButton)
        prepareData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reprepareData), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewAppeard = true
        if isPrepared {
            showContentView()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewAppeard = false
    }
    
    open func prepareData() {
        let isFilterAuthorized = configuration.filterAuthorized
        var _list = permissionList.filter({ $0 != .notification && (!isFilterAuthorized || $0.permissionStatus != .authorized) })
        if permissionList.contains(where: { $0 == .notification }) {
            Permissions.notification.permissionStatusWithCallback({ [weak self] in
                if !isFilterAuthorized || $0 != .authorized {
                    _list.append(Permissions.notification)
                }
                self?.dataSource = _list
                DispatchQueue.main.async {
                    self?.reloadData()
                }
            })
        } else {
            dataSource = _list
            reloadData()
        }
    }
    
    open func reloadData() {
        if dataSource.isEmpty {
            dismiss(animated: isShowing)
        } else {
            tableView.reloadData()
            tableView.layoutIfNeeded()
            let height = tableView.contentSize.height + 20
            heightConstraint.constant = min(height, UIScreen.main.bounds.height - view.safeAreaInsets.bottom * 2)
            isPrepared = true
            if isViewAppeard {
                showContentView()
            }
        }
    }
    
    @objc private func touchDismissAction() {
        dismissContentView()
    }
    
    @objc private func reprepareData() {
        isPrepared = false
        prepareData()
    }
    
    private func showContentView() {
        UIView.animate(withDuration: 0.25, delay: 0, animations: {
            self.contentView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { _ in
            self.isShowing = true
        })
    }
    
    private func dismissContentView() {
        UIView.animate(withDuration: 0.25, delay: 0, animations: {
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.iphone_height)
        }, completion: { _ in
            self.dismiss(animated: true)
        })
    }
}

extension PermissionAlertController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        -1
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.selectionStyle = .none
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let permission = dataSource[indexPath.row]
        let infoAttributes = configuration.infoAttribute?[permission]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PermissionAlertCell", for: indexPath) as! PermissionAlertCell
        cell.reloadPermission(dataSource[indexPath.row],
                              infoAttribute: infoAttributes,
                              buttonAttribute: configuration.statusButtonAttribute,
                              delegate: self,
                              at: indexPath)
        return cell
    }
}

extension PermissionAlertController: PermissionAlertCellDelegate {
    public func permissionCell(_ cell: PermissionAlertCell, didTapedStatusButtonAt indexPath: IndexPath) {
        let permission = dataSource[indexPath.row]
        if permission == .notification {
            permission.permissionStatusWithCallback { [weak self] status in
                self?.requestAuthorizationIfNeeded(permission, status: status, at: indexPath)
            }
        } else {
            requestAuthorizationIfNeeded(permission, status: permission.permissionStatus, at: indexPath)
        }
    }
    
    public func requestAuthorizationIfNeeded(_ permission: Permissions, status: PermissionStatus, at indexPath: IndexPath) {
        permission.requestAuthorizionWithCallback(self, redirectToSettingsIfDenied: configuration.redirectToSettingsIfDenied) { [weak self] newStatus in
            if status != newStatus {
                if newStatus == .authorized, self?.configuration.filterAuthorized == true {
                    self?.reprepareData()
                } else {
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
}
