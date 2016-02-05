Pod::Spec.new do |s|
  s.name     = 'AlgoliaSearch-Client'
  s.version  = '3.6.4'
  s.license  = 'MIT'
  s.summary  = 'Algolia Search API Client for iOS & OS X written in Objective-C.'
  s.homepage = 'https://github.com/algolia/algoliasearch-client-objc'
  s.author   = { 'Algolia' => 'contact@algolia.com' }
  s.source   = { :git => 'https://github.com/algolia/algoliasearch-client-objc.git', :tag => s.version }

  s.ios.deployment_target = '6.0'
  s.ios.frameworks = 'MobileCoreServices', 'SystemConfiguration', 'Security'

  s.osx.deployment_target = '10.8'
  s.osx.frameworks = 'CoreServices', 'SystemConfiguration', 'Security'

  s.source_files = 'src/*.{h,m}'
  s.private_header_files = 'src/ASExpiringCache*.h'

  s.dependency 'AFNetworking', '~> 2.2'
end
