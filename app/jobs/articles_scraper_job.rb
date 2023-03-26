class ArticlesScraperJob < ApplicationJob
  queue_as :default

  def perform
    news_website = "https://www.theverge.com/"
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--no-sandbox')
    browser = Watir::Browser.new(:chrome, options: options)
    browser.goto(news_website)
    page = Nokogiri::HTML.parse(browser.html)

    # most articles format
    most_articles = page.css("h2 a")
    most_articles.each do |a|
      begin
        title = a.text
        next if title == "Advertiser Content" || title == "Taken for a ride"
        url = a["href"]
        published_at = Chronic.parse(a.parent.parent.parent.css(".text-gray-63").text)
        Article.create(title: title, url: "#{news_website}#{url}", published_at: published_at)
      rescue ArgumentError => e
        logger.debug "ArgumentError: #{e.message}"
        next
      end
    end

    # right side articles
    right_sticky_articles = page.css("a h3")
    right_sticky_articles.each do |a|
      begin
        parent = a.parent
        title = parent.text
        url = parent["href"]
        published_at = Chronic.parse(a.parent.parent.parent.css(".font-light").text)
        Article.create(title: title, url: "#{news_website}#{url}", published_at: published_at)
      rescue ArgumentError => e
        logger.debug "ArgumentError: #{e.message}"
        next
      end
    end

    # large content cards
    large_content_cards = page.xpath("//div[contains(@class, 'duet--content-cards--content-card')]/a")
    large_content_cards.each do |a|
      begin
        title = a["aria-label"]
        url = a["href"]
        published_at = Chronic.parse(a.parent.css(".font-normal").text)
        published_at = Chronic.parse(a.parent.css(".text-gray-63").text) if a.parent.css(".font-normal").text.empty?
        Article.create(title: title, url: "#{news_website}#{url}", published_at: published_at)
      rescue ArgumentError => e
        logger.debug "ArgumentError: #{e.message}"
        next
      end
    end

    browser.close
  end
end

