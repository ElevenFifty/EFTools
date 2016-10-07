Pod::Spec.new do |spec|
spec.name = "EFTools"
spec.version = "3.0"
spec.summary = "iOS ElevenFifty Toolkit"
spec.homepage = "https://github.com/ElevenFifty/EFTools"
spec.author = { "Brett Keck" => "bkeck@elevenfiftyconsulting.com" }
spec.author = 'ElevenFifty Consulting'
spec.source = { :git => "https://github.com/ElevenFifty/EFTools.git", :tag => spec.version }
spec.platform = :ios, '9.0'
spec.requires_arc = true

spec.dependency 'MBProgressHUD', '~> 0.9.2'
spec.dependency 'Instabug'
spec.dependency 'TPKeyboardAvoiding'

spec.default_subspec = 'Everything'

spec.subspec 'Basic' do |basic|
    basic.source_files = 'EFTools/Basic'
end

spec.subspec 'Alamofire' do |afspec|
    afspec.dependency 'Alamofire', '~> 4.0'
    afspec.dependency 'Freddy', '~> 3.0'
    afspec.dependency 'Valet'
    afspec.source_files = 'EFTools/AF', 'EFTools/Basic'
end

spec.subspec 'Everything' do |allspec|
    allspec.dependency 'Alamofire', '~> 4.0'
    allspec.dependency 'Freddy', '~> 3.0'
    allspec.dependency 'Valet'
    allspec.source_files = 'EFTools/AF', 'EFTools/Basic'
end

end
