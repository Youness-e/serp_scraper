require 'uri'
require 'mechanize'
require 'addressable/uri'
require 'nokogiri'
require 'deathbycaptcha'
require 'watir'

class SerpScraper
  attr_accessor :engine

  def initialize(params)
    engine = params[:engine] || 'google'
    tld = params[:tld] || 'com'

    case engine
    when "google"
      @engine = Google.new(tld)
    end
  end

  def set_proxy(address, port, user = nil, password = nil)
    # @todo: deprecated message for user & password
    @engine.set_proxy(address, port)
  end

  def deathbycaptcha(username, password)
    @engine.dbc = DeathByCaptcha.new(username, password, :http)
  end

  def search(keyword)
    @engine.search(keyword)
  end
end

def hund
  s = SerpScraper.new(engine: 'google', tld: 'se')
  s.search("vad är min ip")
end

def katt
  s = SerpScraper.new(engine: 'google', tld: 'se')

  s.deathbycaptcha('ranktracker', 'rd41e21970')
  s.engine.parameter('hl', 'sv')
  s.set_proxy('191.101.72.152', 80)

  k = s.search("mitt ipnr")
  k.organic.each do |result|
    puts result[:position].to_s + " -> " + result[:domain].to_s
  end
end

require 'engines/google'
require 'serp_response'