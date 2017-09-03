Gem::Specification.new do |s|
  s.name        = 'serp_scraper'
  s.version     = '2.0.7'
  s.date        = '2017-05-26'

  s.homepage    = 'https://github.com/kjellberg'
  s.summary     = %q{Get rankings from Search Engines}
  s.description = "SERP Scraper is a ruby library that extracts keyword rankings from Google."
  

  s.authors     = ["Rasmus Kjellberg"]
  s.email       = 'rk@youngmedia.se'
  s.license     = 'MIT'

  s.require_paths = ["lib"]
  s.files       = `git ls-files`.split($/)

  s.add_runtime_dependency 'mechanize', '~> 2.7.0'
  s.add_runtime_dependency 'addressable', '~> 2.5'
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'deathbycaptcha', '~> 5.0.0'
end
