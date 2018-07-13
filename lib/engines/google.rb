class SerpScraper::Google
  attr_accessor :tld
  attr_accessor :user_agent
  attr_accessor :browser
  attr_accessor :dbc
  attr_accessor :parameters

  def initialize(tld)
    @tld = tld

    # Set standard query parameters
    @parameters = {
      gbv: 1, # 1=no javascript, 2=javascript.
      complete: 0, # Do not use autocomplete
      num: 100, # 100 results per page
      pws: 0, # Remove history-based personalization (personalization)
      nfpr: 0, # Turn on auto correction of spelling
      ie: 'utf-8',
      oe: 'utf-8',
      site: 'webhp',
      source: 'hp'
    }

    @address, @port, @user, @password = nil, nil, nil, nil
  end

  def set_proxy(address, port, user = nil, password = nil)
    @address, @port, @user, @password = address, port, user, password
  end

  def search(keyword)
    # Add keyword to parameters
    @parameters['q'] = keyword

    # Create build google search url
    search_url = build_query_url_from_keyword(keyword)
    result = nil

    begin
      Mechanize.start do |browser|
        browser.user_agent_alias = ['Windows IE 7', 'Mac Safari'].sample
        browser.max_history = 5
        browser.set_proxy(@address, @port, @user, @password)
        sleep(0.5)
        # Do the Googleing
        browser.get("https://www.google.#{@tld}")
        sleep(rand(4.0..8.5))
        response = browser.get(search_url)
        result = build_serp_response(response, browser)
      end
      return result
    rescue Mechanize::ResponseCodeError => e
      case e.response_code.to_i
      when 503
        raise SerpScraper::CaptchaException
      end
    end

  end

  def build_serp_response(response, browser)

    sr            = SerpScraper::SerpResponse.new
    sr.keyword    = @parameters['q']
    sr.user_agent = browser.user_agent
    sr.url        = response.uri.to_s
    sr.html       = response.content
    sr.organic    = extract_organic(sr.html)
    sr.adwords    = extract_adwords(sr.html)

    sr # Return sr
  end

  def extract_adwords(html)
    doc     = Nokogiri::HTML(html)
    results = Array.new
  end

  def extract_organic(html)
    doc = Nokogiri::HTML(html)
    results = Array.new

    rows = doc.css("#ires > ol > .g")


    position = 0
    rows.each do |row|

      next unless row.at('h3.r a')
      position += 1
      extras = []
      sublinks = []

      # Check for featured snippet box container.
      if row.at('.hp-xpdbox')
        extras << 'featured_snippet'
      end

      # Check for sub links.
      if row.at('.osl')
        extras << 'sublinks'
        row.at('.osl').css('a').each do |link|
          href = Addressable::URI.parse(link["href"])
          external_link = href.query_values['q']    unless href.query_values['q'] == nil
          external_link = href.query_values['url']  unless href.query_values['url'] == nil
          next if external_link.nil?
          external_link = Addressable::URI.parse(external_link)
          sublinks << { title: link.content, url: external_link.request_uri }
        end
      end

      # Check for cached version links.
      if row.at('.A8ul6')
        extras << 'cached'
      end

      # Find title element
      title_element = row.at('h3.r a')
      next unless title_element && title_element["href"] && title_element["href"].length > 3

      # Parse url from title element
      href = Addressable::URI.parse(title_element["href"])
      external_url = href.query_values['q']    unless href.query_values['q'] == nil
      external_url = href.query_values['url']  unless href.query_values['url'] == nil
      next if external_url.nil?

      url = Addressable::URI.parse(external_url)
      next if url.nil?

      # Only add valid URL's (ignore images, news etc)
      unicode_domain = SimpleIDN.to_unicode(url.host)

      results << {
        position: position,
        title: title_element.content,
        scheme: url.scheme,
        domain: unicode_domain,
        url: url.request_uri,
        full_url: "#{url.scheme}://#{unicode_domain}#{url.request_uri}",
        extras: extras,
        sublinks: sublinks
      }

    end

    results
  end

  def parameter(key, value)
    @parameters[key] = value
  end

  def build_query_url_from_keyword(keyword)
    uri = Addressable::URI.new
    uri.host = "www.google.#{@tld}"
    uri.scheme = "https"
    uri.path = "/search"
    uri.query_values = @parameters
    uri.to_s
  end
end
