# SERP Scraper examples

## Basic search
```ruby
require 'serp_scraper'

s = SerpScraper.new(engine: 'google')
response = s.search('buy cars onlines')

response.results.each do |result|
  puts result
  # => {:position=>1, :title=>"Buying From CarMax", :scheme=>"https", :domain=>"www.carmax.com", :url=>"/car-buying-process", :full_url=>"https://www.carmax.com/car-buying-process"}
end
```

## Country/TLD specific search
```ruby
# Set '.se' as TLD for swedish results
s = SerpScraper.new(engine: 'google', tld: 'se')

# Set language parameter to swedish
s.engine.parameter('hl', 'sv')

s.search('köp bilar online').results.each do |result|
  puts result
  # => {:position=>1, :title=>"kvd.se - Bilauktioner på nätet", :scheme=>"https", :domain=>"www.kvd.se", :url=>"/", :full_url=>"https://www.kvd.se/"}
end
```

## Use DeathByCaptcha to solve 503 errors (captcha)
```ruby
google = SerpScraper.new(engine: 'google', tld: 'com')
google.deathbycaptcha('dbc username', 'dbc password')
google.search('casino bonus').results[0]
# => {:position=>1, :title=>"Buying From CarMax", :scheme=>"https", :domain=>"www.carmax.com", :url=>"/car-buying-process", :full_url=>"https://www.carmax.com/car-buying-process"}
```

## Hide servers IP with proxies
```ruby
google = SerpScraper.new(engine: 'google', tld: 'com')
google.set_proxy(host, port, user, password)
google.search('casino bonus').results[0]
# => {:position=>1, :title=>"Buying From CarMax", :scheme=>"https", :domain=>"www.carmax.com", :url=>"/car-buying-process", :full_url=>"https://www.carmax.com/car-buying-process"}
```