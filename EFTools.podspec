Pod::Spec.new do |spec|
spec.name         = "EFTools"
spec.version      = "0.3"
spec.summary      = "iOS ElevenFifty Toolkit"
spec.homepage     = "https://github.com/ElevenFifty/EFTools"
spec.author       = { "Brett Keck" => "bkeck@elevenfiftyconsulting.com" }
spec.author       = 'ElevenFifty Consulting'
spec.source       = { :git => "https://barryllium@github.com/ElevenFifty/EFTools.git", :tag => "0.3" }
spec.platform     = :ios, '8.0'
spec.requires_arc = true

spec.dependency 'SnapKit'
spec.dependency 'MBProgressHUD', '~> 0.9.1'
spec.dependency 'AFDateHelper'
spec.dependency 'Instabug'
spec.dependency 'TPKeyboardAvoiding'

spec.default_subspec = 'Everything'

spec.subspec 'Basic' do |basic|
    basic.source_files = 'EFTools/Basic'
end

spec.subspec 'Parse' do |parsespec|
    parsespec.dependency 'ParseUI'
    parsespec.dependency 'ParseFacebookUtilsV4'
    parsespec.dependency 'ParseTwitterUtils'
    parsespec.source_files = 'EFTools/Parse', 'EFTools/Basic'
end

spec.subspec 'Alamofire' do |afspec|
    afspec.dependency 'Alamofire', '~> 3.5'
    afspec.dependency 'SwiftyJSON'
    afspec.dependency 'SwiftKeychainWrapper'
    afspec.source_files = 'EFTools/AF', 'EFTools/Basic'
end

spec.subspec 'Everything' do |allspec|
    allspec.dependency 'ParseUI'
    allspec.dependency 'ParseFacebookUtilsV4'
    allspec.dependency 'ParseTwitterUtils'
    allspec.dependency 'Alamofire', '~> 3.5'
    allspec.dependency 'SwiftyJSON'
    allspec.dependency 'SwiftKeychainWrapper'
    allspec.source_files = 'EFTools/Parse', 'EFTools/AF', 'EFTools/Basic'
end


end
