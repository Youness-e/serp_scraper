class SerpScraper::Google
  attr_accessor :tld
  attr_accessor :user_agent

  def initialize
    @browser = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
    
    @parameters = Hash.new 
    @parameters['gbv'] = 1
    @parameters['complete'] = 0
    @parameters['num'] = 100
    @parameters['pws'] = 0
    @parameters['nfrpr'] = 1
    @parameters['ie'] = 'utf-8'
    @parameters['oe'] = 'utf-8'
    @parameters['site'] = 'webhp'
    @parameters['source'] = 'hp'

    self.tld = 'se'
  end

  def search(keyword)
    # Do the Googleing
    http_response = @browser.get(build_query_url_from_keyword(keyword))
    
    return build_serp_response(http_response) if http_response.code == "200"

    # @todo: Look for and solve captchas.
    puts "Did not get a 200 response. Maybe a captcha error?"
  end

  def build_serp_response(http_response)
    sr            = SerpScraper::SerpResponse.new
    sr.keyword    = @parameters['q']
    sr.user_agent = @browser.user_agent
    sr.url        = http_response.uri.to_s
    sr.html       = http_response.content
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
    @parameters['q'] = keyword

    uri = Addressable::URI.new
    uri.host = "www.google.#{tld}"
    uri.scheme = "https"
    uri.path = "/search"
    uri.query_values = @parameters
    uri.to_s
  end
end