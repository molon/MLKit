Pod::Spec.new do |s|
s.name         = "MLKit"
s.version      = "0.1.4"
s.summary      = "MLKit"

s.homepage     = 'https://github.com/molon/MLKit'
s.license      = { :type => 'MIT'}
s.author       = { "molon" => "dudl@qq.com" }

s.source       = {
:git => "https://github.com/molon/MLKit.git",
:tag => "#{s.version}"
}

s.requires_arc  = true
s.platform     = :ios, '7.0'
s.public_header_files = 'Classes/**/*.h'
s.source_files  = 'Classes/**/*.{h,m}'
s.resource = "Classes/**/*.{bundle}"
s.libraries = 'z'

s.dependency 'MLPersonalModel', '~> 11.1.0'
s.dependency 'SAMKeychain', '~> 1.5.1'
s.dependency 'DHSmartScreenshot', '~> 1.3.1'
s.dependency 'AFNetworking' , '~> 2.6.3' #, '~> 3.1.0'
s.dependency 'YYCache', '~> 1.0.3'
s.dependency 'CocoaLumberjack', '~> 2.3.0'
s.dependency 'MLRefreshControl', '~> 0.1.1'
s.dependency 'MLLayout', '~> 0.3.1'

end
