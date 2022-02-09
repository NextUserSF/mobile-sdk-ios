Pod::Spec.new do |s|
  s.name             = 'NextUser'
  s.version          = '2.0.2'
  s.summary          = 'NextUser analytics for IOS.'
  s.description      = 'NextUser SDK for IOS platform'

  s.homepage         = 'https://github.com/NextUserSF/mobile-sdk-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Next User' => 'a.lazea@gmail.com' }
  s.source           = { :git => 'https://github.com/NextUserSF/mobile-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.source_files = 'NextUser/Classes/**/*.{h,m}'
  s.public_header_files = 'NextUser/Classes/Public/**/*.h'
  s.resource_bundles = {
    'NextUser' => ['NextUser/Assets/*.png']
  }

  s.frameworks = 'SystemConfiguration','UserNotifications'

  s.dependency 'CocoaLumberjack'
  s.dependency 'AFNetworking'
  
end
