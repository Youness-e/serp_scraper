Gem::Specification.new do |s|
  s.name        = 'serp_scraper'
  s.version     = '0.0.1'
  s.date        = '2017-05-26'
  s.summary     = "Scrape search engine keyword positions."
  s.description = "Scrape search engine keyword positions."
  s.authors     = ["Rasmus Kjellberg"]
  s.email       = 'rk@youngmedia.se'
  s.files       = ["lib/serp_scraper.rb", "lib/engines/google.rb", "lib/serp_response.rb"]
  s.homepage    = 'https://github.com/kjellberg'
  s.license     = 'MIT'
  s.add_runtime_dependency 'mechanize', '~> 2.7', '>= 2.7.5'
  s.add_runtime_dependency 'addressable', '~> 2.5'
  s.add_runtime_dependency 'nokogiri', '~> 2.9', '>= 2.9.4'
end