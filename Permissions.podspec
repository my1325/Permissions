Pod::Spec.new do |s|

 s.name             = "Permissions"
 s.version           = "0.0.5"
 s.summary         = "A light weight iOS Permission Authorization manager"
 s.homepage        = "https://github.com/my1325/Permissions.git"
 s.license            = "MIT"
 s.platform          = :ios, "12.0"
 s.authors           = { "mayong" => "1173962595@qq.com" }
 s.source             = { :git => "https://github.com/my1325/Permissions.git", :tag => "#{s.version}" }
 s.swift_version = '5.1'
 s.default_subspecs = 'Core'

 s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/PermissionsCore/*.swift'
 end

 s.subspec 'AppTracking' do |ss|
    ss.source_files = 'Sources/AppTracking/*.swift'
    ss.dependency 'Permissions/Core'
 end 

 s.subspec 'Notification' do |ss|
    ss.source_files = 'Sources/Notification/*.swift'
    ss.dependency 'Permissions/Core'
 end 

 s.subspec 'AVDevice' do |ss|
    ss.source_files = 'Sources/AVDevice/*.swift'
    ss.dependency 'Permissions/Core'
 end 

 s.subspec 'PhotoLibrary' do |ss|
    ss.source_files = 'Sources/PhotoLibrary/*.swift'
    ss.dependency 'Permissions/Core'
 end 

 s.subspec 'Location' do |ss|
    ss.source_files = 'Sources/Location/*.swift'
    ss.dependency 'Permissions/Core'
 end
 
 s.subspec 'Contact' do |ss|
    ss.source_files = 'Sources/Contact/*.swift'
    ss.dependency 'Permissions/Core'
 end
 
 s.subspec 'Event' do |ss|
    ss.source_files = 'Sources/Event/*.swift'
    ss.dependency 'Permissions/Core'
 end
end
