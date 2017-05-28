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
gem 'serp_scraper'
```

## Examples

```ruby 
google = SerpScraper.new(engine: 'google', tld: 'com')
first_result = google.search('buy cars onlines').results[0]
puts first_result
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
