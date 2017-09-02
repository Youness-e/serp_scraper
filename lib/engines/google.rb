class SerpScraper::Google
  attr_accessor :tld
  attr_accessor :user_agent
  attr_accessor :browser
  attr_accessor :dbc

  def initialize(tld)
    # Make tld global
    @tld = tld

    # Empty proxy
    @proxy = nil

    # Create new Mechanize object
    # @browser = Mechanize.new { |agent|
    #   agent.user_agent = 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko'
    # }

    # Set standard query parameters
    @parameters = {
      gbv: 1,
      complete: 0,
      num: 100,
      pws: 0,
      nfrpr: 1,
      ie: 'utf-8',
      oe: 'utf-8'
    }
  end

  def set_proxy(address, port)
    @proxy = "#{address}:#{port}"
  end

  def search(keyword)
    # Add keyword to parameters
    @parameters['q'] = keyword

    if @proxy
      @browser = Watir::Browser.new :chrome, :switches => ["--proxy-server=#{@proxy}"]
    else
      @browser = Watir::Browser.new :chrome
    end

    @google_url = "https://www.google.#{@tld}?num=100&complete=0&pws=0&nfrpr=1&ie=utf-8&oe=utf-8&hl=sv"

    begin
      @browser.goto @google_url
      @browser.text_field(name: 'q').set keyword
      @browser.button(name: 'btnK').click

      html = @browser.html
      return build_serp_response
    rescue
      raise 'Error. Probably blocked by CAPTCHA or something'
    end
  end

  def _search(keyword)

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

    puts doc

    begin
      image_url = Addressable::URI.parse('http://ipv4.google.com' + doc.css('img')[0]["src"])
      image = @browser.get(image_url.to_s)
    rescue
      raise "Could not find CAPTCHA-image"
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

  def build_serp_response
    sr            = SerpScraper::SerpResponse.new
    sr.keyword    = @parameters['q']
    sr.user_agent = nil # @todo: fix 
    sr.url        = nil
    sr.html       = @browser.html
    sr.organic    = extract_organic(@browser.html)
    sr.adwords    = extract_adwords(@browser.html)

    sr # Return sr
  end

  def extract_adwords(html)
    doc     = Nokogiri::HTML(html)
    results = Array.new
  end

  def extract_organic(html)
    doc     = Nokogiri::HTML(html)
    results = Array.new

    rows = doc.css("h3.r a:not(.sla)")

    position = 1
    rows.each do |row|
      
        href = Addressable::URI.parse(row["href"])

        # puts row

        # external_url = href.query_values['q']    unless href.query_values['q'] == nil
        # external_url = href.query_values['url']  unless href.query_values['url'] == nil

        external_url = href

        url = Addressable::URI.parse(external_url)
        next unless url.host # Only add valid URL's (ignore images, news etc)

        results << {
          position: position,
          title: row.content,
          scheme: url.scheme,
          domain: url.host,
          url: url.request_uri,
          full_url: url.to_s
        }

        position += 1

      
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