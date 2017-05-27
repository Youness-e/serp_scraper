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

  def search(keyword)
    @engine.search(keyword)
  end
end

def test
  google = SerpScraper.new(engine: 'google', tld: 'se')

  # Set language to Swedish
  google.engine.parameter('hl', 'sv')

  # GO, FETCH!
  response = google.search("casino faktura")

  # Return search results
  response.results
end

require 'uri'
require 'mechanize'
require 'addressable/uri'
require 'nokogiri'
require 'engines/google'
require 'serp_response'