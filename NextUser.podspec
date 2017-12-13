Pod::Spec.new do |s|
  s.name             = 'NextUser'
  s.version          = '1.0.9'
  s.summary          = 'NextUser analytics for IOS.'
  s.description      = 'NextUser SDK for IOS platform'
  s.homepage         = 'https://github.com/NextUserSF/mobile-sdk-ios'
  s.author           = { 'Next User' => 'marin@nextuser.com' }
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/NextUserSF/mobile-sdk-ios.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.dependency 'CocoaLumberjack'
  s.dependency 'AFNetworking', '~> 3.0'
  s.dependency 'SAMKeychain'
  s.dependency 'Base64'
  s.framework = 'SystemConfiguration'

  s.default_subspec = 'Production'

  s.ios.deployment_target = '8.0'

  s.public_header_files = 'NextUser/Classes/Public/**/*.h'
  s.source_files = 'NextUser/Classes/**/*.{h,m}'
  s.resource_bundles = {
    'NextUser' => ['NextUser/Assets/*.png']
  }
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/NextUser/**"',
  'ENABLE_BITCODE' => 'YES' }

  s.subspec 'Production' do |prod|
    prod.public_header_files = 'NextUser/Classes/Public/**/*.h'
    prod.source_files  = 'NextUser/Classes/**/*.{h,m}'
  end

end
