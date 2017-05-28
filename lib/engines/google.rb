class SerpScraper::Google
  attr_accessor :tld
  attr_accessor :user_agent
  attr_accessor :browser

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
      pws: 0,
      nfrpr: 1,
      ie: 'utf-8',
      oe: 'utf-8',
      site: 'webhp',
      source: 'hp'
    }
  end

  def search(keyword)
    # Add keyword to parameters
    @parameters['q'] = keyword

    # Create build google search url
    search_url = build_query_url_from_keyword(keyword)

    # Do the Googleing
    response = @browser.get(search_url, :referer => "https://www.google.#{@tld}")

    # 503 error = Google Captcha
    tries = 1 
    while response.code[/503/] and tries <= 3
      # Try to solve with captcha 
      solve_captcha(response.uri.to_s)

      # Do another search
      response = @browser.get(search_url)

      tries += 1
    end
    
    return build_serp_response(response) if response.code == "200"

    # @todo: Look for and solve captchas.
    puts "Did not get a 200 response. Maybe a captcha error?"
  end

  def solve_captcha(captcha_url)
    puts "trying to solve captcha on url #{captcha_url}"
    
    page = @browser.get(captcha_url)
    doc = Nokogiri::HTML(page.content)

    image_url = Addressable::URI.parse('http://ipv4.google.com/' + doc.css('img')[0]["src"]).normalize
    puts "Captcha url: " + image_url
  end

  def build_serp_response(response)
    sr            = SerpScraper::SerpResponse.new
    sr.keyword    = @parameters['q']
    sr.user_agent = @browser.user_agent
    sr.url        = response.uri.to_s
    sr.html       = response.content
    sr.results    = extract_results(sr.html)

    sr # Return sr
  end

  def extract_results(html)
    doc     = Nokogiri::HTML(html)
    results = Array.new

    rows = doc.css('h3.r > a')
    rows.each_with_index do |row, i|
      begin
        href = Addressable::URI.parse(row["href"])

        external_url = href.query_values['q']    unless href.query_values['q'] == nil
        external_url = href.query_values['url']  unless href.query_values['url'] == nil

        url = Addressable::URI.parse(external_url)

        results.push({
          position: i + 1,
          title: row.content,
          scheme: url.scheme,
          domain: url.host,
          url: url.request_uri,
          full_url: url.to_s
        })
      rescue
        next
      end
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