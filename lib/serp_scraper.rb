class SerpScraper
  attr_accessor :engine

  def initialize(engine = "google")
    case engine
    when "google"
      @engine = Google.new
    end
  end

  def search(keyword)
    @engine.search(keyword)
  end
end

def test
  google    = SerpScraper.new("google")
  response  = google.search("casino faktura")
  response
end

require 'uri'
require 'mechanize'
require 'addressable/uri'
require 'nokogiri'
require 'engines/google'
require 'serp_response'