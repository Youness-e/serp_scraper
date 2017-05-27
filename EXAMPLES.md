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
# Usees google.se for swedish results
s = SerpScraper.new(engine: 'google', tld: 'se')

# Set language to Swedish
s.engine.parameter('hl', 'sv')

response = s.search('köp bilar online')
```