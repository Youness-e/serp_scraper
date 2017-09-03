class SerpScraper::SerpResponse
  attr_accessor :keyword
  attr_accessor :url
  attr_accessor :user_agent
  attr_accessor :proxy
  attr_accessor :organic
  attr_accessor :adwords
  attr_accessor :html

  def results
    warn "[DEPRECATION] `results` is deprecated.  Please use `organic` instead!"
    organic
  end
end