
Pod::Spec.new do |s|
  s.name         = "CYNavigationController"
  s.version      = "1.0.0"
  s.summary      = "CYNavigationController is screenPopController."
  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/candy7/CYNavigationController.git" 
  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
 
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
 
  s.author             = { "whq" => "whq_candy@163.com" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
   
 
  s.source       = { :git => "https://github.com/candy7/CYNavigationController.git", :tag => "#{s.version}" }
  
  s.ios.deployment_target = '8.0'
  # s.source_files = 'CTMediator/CTMediator/*.{h,m,plist}' #这里的路径要写对
  s.source_files  = "NavigationController/CYNavigationController/*.{h,m}"
  s.platform     = :ios
  s.requires_arc = true 
 
  # s.subspec 'DM' do |ss| #需要group的时候这样搞，比如工程里有个DM文件夹
  #   ss.source_files =  'LogCenter/LogCenter/DM/*.{h,m,mm}'
end
 
 
 
 
end