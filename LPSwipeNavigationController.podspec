Pod::Spec.new do |s|
  s.name         = "LPSwipeNavigationController"
  s.version      = "1.0.0"
  s.summary      = "ARC and GCD Compatible LPSwipeNavigationController Class for iOS"
  s.license      = "MIT"
  s.homepage     = "https://github.com/leapCoding/LPSwipeNavigationController"
  s.author             = { "LeapDev" => "lpdevstore@163.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/leapCoding/LPSwipeNavigationController.git", :tag => "#{s.version}" }
  s.source_files  = "LPSwipeNavigationController/**/*.{h,m}"
end
