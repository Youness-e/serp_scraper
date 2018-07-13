require 'uri'
require 'mechanize'
require 'addressable/uri'
require 'nokogiri'
require 'deathbycaptcha'
require 'simpleidn'

class SerpScraper
  attr_accessor :engine

  def initialize(params = {})
    engine = params[:engine] || 'google'
    tld = params[:tld] || 'com'

    case engine
    when "google"
      @engine = Google.new(tld)
    end
  end

  def set_proxy(address, port, user = nil, password = nil)
    @engine.browser.set_proxy(address, port, user, password)
  end

  def deathbycaptcha(username, password)
    @engine.dbc = DeathByCaptcha.new(username, password, :http)
  end

  def search(keyword)
    @engine.search(keyword)
  end
end

require 'exceptions/captcha'
require 'engines/google'
require 'serp_response'

def test
  s = SerpScraper.new
  s.engine.parameter('hl', 'sv')
  s.engine.parameter('gl', 'se')
 # s.set_proxy('191.102.155.76', 80, 'kjell', 'berg')
  begin
    response = s.search('helglån utan uc')
    response.organic
  rescue SerpScraper::CaptchaException => e
    "Error: #{e.message}"
  end
end
