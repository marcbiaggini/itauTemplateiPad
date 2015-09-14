source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
inhibit_all_warnings!

def import_pods
    pod 'SDKiOS', :git => 'git@10.56.147.16:framework/sdk-ios.git'
    pod 'NSStringMask', '~> 1.2'
    pod 'ReactiveCocoa', '~> 2.3'
    pod 'Facebook-iOS-SDK', '~> 4.1'
end

target :ipaditau do
    import_pods
    #pod 'FLEX'
    #pod 'Reveal-iOS-SDK', :configurations => ['Debug']
end

target :ipad do
    import_pods
    #pod 'FLEX'
    #pod 'Reveal-iOS-SDK', :configurations => ['Debug']
end

#?
#pod 'SDWebImage', '~> 3.7'
