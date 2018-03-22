class SerpScraper::Google
  attr_accessor :tld
  attr_accessor :user_agent
  attr_accessor :browser
  attr_accessor :dbc
  attr_accessor :parameters

  def initialize(tld)
    # Make tld global
    @tld = tld

    # Create new Mechanize object
    @browser = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    # Set standard query parameters
    @parameters = {
      gbv: 1,
      complete: 0,
      num: 100,
      client: 'navclient',
      pws: 0,
      nfrpr: 1,
      ie: 'utf-8',
      oe: 'utf-8',
      site: 'webhp',
      source: 'hp',
      gfe_rd: 'cr'
    }
  end

  def search(keyword)
    # Add keyword to parameters
    @parameters['q'] = keyword

    # Create build google search url
    search_url = build_query_url_from_keyword(keyword)

    begin
      # Do the Googleing
      response = @browser.get(search_url, :referer => "https://www.google.#{@tld}")
      return build_serp_response(response)
    rescue Mechanize::ResponseCodeError => e
      case e.response_code.to_i
      when 503
        if self.dbc
          return try_with_captcha(e.page)
        else
          raise "503: Blocked by captcha :("
        end
      end
    end

  end

  def try_with_captcha(page)    
    #page = @browser.get(captcha_url)
    doc = Nokogiri::HTML(page.body)

    begin
      image_url = Addressable::URI.parse('http://ipv4.google.com' + doc.css('img')[0]["src"])
      image = @browser.get(image_url.to_s)
    rescue
      puts doc
      raise 'Could not find CAPTCHA image'
    end

    # Create a client (:socket and :http clients are available)
    dbc = self.dbc
    captcha = dbc.decode!(raw: image.body)
    
    params = {
      q: image_url.query_values['q'],
      continue: image_url.query_values['continue'],
      id: image_url.query_values['id'],
      captcha: captcha.text,
      submit: 'Submit'
    }

    captcha_response = @browser.get('http://ipv4.google.com/sorry/index', params, page.uri.to_s)
    build_serp_response(captcha_response)
  end

  def build_serp_response(response)

    sr            = SerpScraper::SerpResponse.new
    sr.keyword    = @parameters['q']
    sr.user_agent = @browser.user_agent
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