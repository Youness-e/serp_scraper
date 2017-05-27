# SERP Scraper examples

## Get URL rankings from Google
```ruby
require 'serp_scraper'

google = SerpScraper.new('google')
response = google.search('payday loans')

response.results.each do |result|
  puts "#{result[:position]}: #{result[:full_url]}"
  # => "1: website.com"
end
```
