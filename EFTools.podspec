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
    afspec.dependency 'Alamofire', '< 3.0'
    afspec.dependency 'SwiftyJSON'
    afspec.source_files = 'EFTools/AF', 'EFTools/Basic'
end

spec.subspec 'Everything' do |allspec|
    allspec.dependency 'ParseUI'
    allspec.dependency 'ParseFacebookUtilsV4'
    allspec.dependency 'ParseTwitterUtils'
    allspec.dependency 'Alamofire', '< 3.0'
    allspec.dependency 'SwiftyJSON'
    allspec.source_files = 'EFTools/Parse', 'EFTools/AF', 'EFTools/Basic'
end


end
