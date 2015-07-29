#
# Be sure to run `pod spec lint DrupalKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |spec|
spec.name         = "EFTools"
spec.version      = "0.1"
spec.summary      = "iOS ElevenFifty Toolkit"
# spec.description  = <<-DESC
#                   An optional longer description of EFTools
#
#                   * Markdown format.
#                   * Don't worry about the indent, we strip it!
#                  DESC
spec.homepage     = "https://github.com/ElevenFifty/EFTools"
# spec.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"

# Specify the license type. CocoaPods detects automatically the license file if it is named
# 'LICENCE*.*' or 'LICENSE*.*', however if the name is different, specify it.
# spec.license      = 'MIT'
# spec.license      = { :type => 'MIT (example)', :file => 'FILE_LICENSE' }

# Specify the authors of the library, with email addresses. You can often find
# the email addresses of the authors by using the SCM log. E.g. $ git log
#
spec.author       = { "Brett Keck" => "bkeck@elevenfiftyconsulting.com" }
# spec.authors      = { "Brett Keck" => "bkeck@elevenfiftyconsulting.com", "other author" => "and email address" }
#
# If absolutely no email addresses are available, then you can use this form instead.
#
spec.author       = 'ElevenFifty Consulting'

# Specify the location from where the source should be retrieved.
#
spec.source       = { :git => "https://barryllium@github.com/ElevenFifty/EFTools.git", :tag => "0.1" }


# If this Pod runs only on iOS or OS X, then specify the platform and
# the deployment target.
#
spec.platform     = :ios, '8.0'

# ――― MULTI-PLATFORM VALUES ――――――――――――――――――――――――――――――――――――――――――――――――― #

# If this Pod runs on both platforms, then specify the deployment
# targets.
#
# spec.ios.deployment_target = '6.1'
# spec.osx.deployment_target = '10.7'

# A list of file patterns which select the source files that should be
# added to the Pods project. If the pattern is a directory then the
# path will automatically have '*.{h,m,mm,c,cpp}' appended.
#
# spec.source_files = 'EFTools/Basic'
# spec.exclude_files = 'Classes/Exclude'

# A list of file patterns which select the header files that should be
# made available to the application. If the pattern is a directory then the
# path will automatically have '*.h' appended.
#
# If you do not explicitly set the list of public header files,
# all headers of source_files will be made public.
#
# spec.public_header_files = 'Classes/**/*.h'

# A list of resources included with the Pod. These are copied into the
# target bundle with a build phase script.
#
# spec.resource  = "icon.png"
# spec.resources = "Resources/*.png"

# A list of paths to preserve after installing the Pod.
# CocoaPods cleans by default any file that is not used.
# Please don't include documentation, example, and test files.
#
# spec.preserve_paths = "FilesToSave", "MoreFilesToSave"

# Specify a list of frameworks that the application needs to link
# against for this Pod to work.
#
# spec.framework  = 'SomeFramework'
# spec.frameworks = 'SomeFramework', 'AnotherFramework'

# Specify a list of libraries that the application needs to link
# against for this Pod to work.
#
# spec.library   = 'iconv'
# spec.libraries = 'iconv', 'xml2'

# If this Pod uses ARC, specify it like so.z
#
spec.requires_arc = true

# If you need to specify any other build settings, add them to the
# xcconfig hash.
#
# spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }

# Finally, specify any Pods that this Pod depends on.
#
spec.default_subspec = 'Everything'

spec.subspec 'Basic' do |basic|
    basic.source_files = 'EFTools/Basic'
end

spec.subspec 'Parse' do |parsespec|
    parsespec.dependency 'ParseUI'
    parsespec.dependency 'ParseFacebookUtils'
    parsespec.source_files = 'EFTools/Parse', 'EFTools/Basic'
end

spec.subspec 'Alamofire' do |afspec|
    afspec.dependency 'Alamofire'
    afspec.source_files = 'EFTools/AF', 'EFTools/Basic'
end

spec.subspec 'Everything' do |allspec|
    allspec.dependency 'ParseUI'
    allspec.dependency 'ParseFacebookUtils'
    allspec.dependency 'Alamofire'
    allspec.source_files = 'EFTools/Parse', 'EFTools/AF', 'EFTools/Basic'
end


end