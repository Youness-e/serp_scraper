# SERP Scraper
SERP Scraper is a ruby library that extracts keyword rankings from Google.

##### Supported search engines
* Google

## Installation
Install 'SERP Scraper' from RubyGems:
```sh
$ gem install serp_scraper
```
Or include it in your project's Gemfile with Bundler:
```ruby
gem 'serp_scraper', github: 'kjellberg/serp_scraper'
```

## Examples

```ruby 
google = SerpScraper.new(engine: 'google', tld: 'com')
first_result = google.search('buy cars onlines').organic[0]
puts first_result
# => {:position=>1, :title=>"Buying From CarMax", :scheme=>"https", :domain=>"www.carmax.com", :url=>"/car-buying-process", :full_url=>"https://www.carmax.com/car-buying-process"}
```

#### Basic search
```ruby
require 'serp_scraper'

s = SerpScraper.new(engine: 'google')
response = s.search('buy cars online')

response.organic.each do |result|
  puts result
  # => {:position=>1, :title=>"Buying From CarMax", :scheme=>"https", :domain=>"www.carmax.com", :url=>"/car-buying-process", :full_url=>"https://www.carmax.com/car-buying-process"}
end
```

#### Country/TLD specific search
```ruby
# Set '.se' as TLD for swedish results
s = SerpScraper.new(engine: 'google', tld: 'se')

# Set 'sv' (Swedish) as language parameter
s.engine.parameter('hl', 'sv')

# Set 'se' (Sweden) as country parameter.
s.engine.parameter('gl', 'se')

begin
  response = s.search('casino online')
  puts response.organic
rescue SerpScraper::CaptchaException => e
  puts "Blocked by captcha"
end
```

#### Hide server IP with a proxy
```ruby
google = SerpScraper.new(engine: 'google', tld: 'com')

# Set proxy host (required), port (required), user (optional) and password (optional).
google.set_proxy(host, port, user, password)

google.search('buy cars online').organic[0]
# => {:position=>1, :title=>"Buying From CarMax", :scheme=>"https", :domain=>"www.carmax.com", :url=>"/car-buying-process", :full_url=>"https://www.carmax.com/car-buying-process"}
```

If you are just starting, check out the [EXAMPLES](https://github.com/kjellberg/serp_scraper/blob/master/EXAMPLES.md) file for more examples.

## Support
- [github.com/kjellberg/serp_scraper/issues](https://github.com/kjellberg/serp_scraper/issues)

## Contribute
- [github.com/kjellberg/serp_scraper/issues](https://github.com/kjellberg/serp_scraper/issues)

### Goals
- Add more search engines like Bing & Yahoo

## Dependencies
- [mechanize](https://github.com/sparklemotion/mechanize)
- [nokogiri](https://github.com/sparklemotion/nokogiri)
- [addressable/uri](https://github.com/sporkmonger/addressable)

## Credits
- [github.com/kjellberg](https://github.com/kjellberg) 

*Make a [pull request](https://github.com/kjellberg/serp_scraper/#contribute) and add your name here :)*

## License
This library is distributed under the MIT license.
