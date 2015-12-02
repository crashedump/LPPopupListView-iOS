Pod::Spec.new do |s|
  s.name         = "LPPopupListView@Color"
  s.version      = "1.0.3.3"
  s.summary      = "LPPopupListView is custom popup component for iOS with table for single or multiple selection."
  s.homepage     = "https://github.com/crashedump/LPPopupListView"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Luka Penger' => 'luka.penger@gmail.com', 'Crash Dump' => 'crash.dump@mail.ru' }
  s.source       = { :git => "https://github.com/crashedump/LPPopupListView-iOS.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.source_files = 'LPPopupListView/**/*.{h,m}'
  s.resources    = 'LPPopupListView/**/Images/*.png'
  s.frameworks    = "CoreLocation","AVFoundation"
  s.requires_arc = true
end