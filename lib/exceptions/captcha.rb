class SerpScraper::CaptchaException < StandardError
  def initialize(msg="503: Blocked by captcha")
    super
  end
end