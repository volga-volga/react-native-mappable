require "json"

Pod::Spec.new do |s|
    package = JSON.parse(File.read(File.join(File.dirname(__FILE__), "package.json")))
    s.name         = "RNMappable"
    s.version      = package["version"]
    s.summary      = package["description"]
    s.homepage     = "vvdev.ru"
    s.license      = "MIT"
    s.author       = { package["author"]["name"] => package["author"]["email"] }
    s.platform     = :ios, "12.0"
    s.source       = { :git => "https://github.com/author/RNMappable.git", :tag => "master" }
    s.source_files = "ios/**/*.{h,m,swift}"
    # s.requires_arc = true

    s.dependency "React"
    s.dependency "MappableMobile", "1.1.0-full"
end
