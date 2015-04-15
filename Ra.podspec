Pod::Spec.new do |s|
  s.name         = "Ra"
  s.version      = "0.3.0"
  s.summary      = "A Dependency Injection framework for Swift."

  s.homepage     = "https://github.com/younata/Ra"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = "Rachel Brindle"
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/younata/Ra.git" }
  s.source_files  = "Ra", "Ra/**/*.{swift,h,m}"

  s.framework = "XCTest"
  s.requires_arc = true
end
