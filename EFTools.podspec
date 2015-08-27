Pod::Spec.new do |spec|
spec.name         = "EFTools"
spec.version      = "0.2"
spec.summary      = "iOS ElevenFifty Toolkit"
spec.homepage     = "https://github.com/ElevenFifty/EFTools"
spec.author       = { "Brett Keck" => "bkeck@elevenfiftyconsulting.com" }
spec.author       = 'ElevenFifty Consulting'
spec.source       = { :git => "https://barryllium@github.com/ElevenFifty/EFTools.git", :tag => "0.2" }
spec.platform     = :ios, '8.0'
spec.requires_arc = true

#spec.dependency 'SnapKit', :git => 'https://github.com/SnapKit/SnapKit', :branch => 'swift-2.0'
spec.dependency 'MBProgressHUD', '~> 0.9.1'
#spec.dependency 'AFDateHelper', :git => 'https://github.com/melvitax/AFDateHelper', :branch => 'Swift2'
spec.dependency 'Instabug'
spec.dependency 'TPKeyboardAvoiding'

spec.default_subspec = 'Everything'

spec.subspec 'Basic' do |basic|
    basic.source_files = 'EFTools/Basic'
end

spec.subspec 'Parse' do |parsespec|
    parsespec.dependency 'ParseUI'
    parsespec.dependency 'ParseFacebookUtils'
    parsespec.dependency 'ParseTwitterUtils'
    parsespec.source_files = 'EFTools/Parse', 'EFTools/Basic'
end

spec.subspec 'Alamofire' do |afspec|
#    afspec.dependency 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :branch => 'swift-2.0'
#    afspec.dependency 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON', :branch => 'xcode7'
    afspec.source_files = 'EFTools/AF', 'EFTools/Basic'
end

spec.subspec 'Everything' do |allspec|
    allspec.dependency 'ParseUI'
    allspec.dependency 'ParseFacebookUtils'
    allspec.dependency 'ParseTwitterUtils'
#    allspec.dependency 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :branch => 'swift-2.0'
#    allspec.dependency 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON', :branch => 'xcode7'
    allspec.source_files = 'EFTools/Parse', 'EFTools/AF', 'EFTools/Basic'
end


end
