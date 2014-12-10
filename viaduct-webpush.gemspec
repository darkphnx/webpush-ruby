Gem::Specification.new do |s|
  s.name        = "viaduct-webpush"
  s.version     = '1.0.3'
  s.authors     = ["Adam Cooke"]
  s.email       = ["adam@viaduct.io"]
  s.homepage    = "http://viaduct.io"
  s.summary     = "A client library for the Viaduct WebPush API."
  s.description = "A client library allows messages to be sent to the WebPush API."
  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "Gemfile"]

  s.add_development_dependency "bundler", "~> 1.6"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_dependency "json", ">= 1.8", "< 2"
  s.add_dependency "websocket", "~> 1.2"
  
  s.licenses    = ["MIT"]
end
