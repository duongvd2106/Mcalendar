source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!
target 'MCalendar' do
    pod 'CVCalendar', '~> 1.4.0'
    pod 'MagicalRecord'
    pod 'GoogleMaps'
    pod 'GooglePlaces'
end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
