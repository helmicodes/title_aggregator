class ArticlesScraperJob < ApplicationJob
  queue_as :default

  def perform
    news_website = "https://www.theverge.com/"
    browser = Watir::Browser.new(:chrome, headless: true)
    browser.goto(news_website)
    Watir::Wait.until(timeout: 10) { browser.ready_state == 'complete' }
    page = Nokogiri::HTML.parse(browser.html)

    # most articles format
    most_articles = page.css("h2 a")
    most_articles.each do |a|
      title = a.text
      next if title == "Advertiser Content" || title == "Taken for a ride"
      url = a["href"]
      published_at = a.parent.parent.parent.css(".text-gray-63").text.to_time
      Article.create(title: title, url: "#{news_website}#{url}", published_at: published_at)
    end

    # right side articles
    right_sticky_articles = page.css("a h3")
    right_sticky_articles.each do |a|
      parent = a.parent
      title = parent.text
      url = parent["href"]
      published_at = a.parent.parent.parent.css(".font-light").text.to_time
      Article.create(title: title, url: "#{news_website}#{url}", published_at: published_at)
    end

    # large content cards
    large_content_cards = page.xpath("//div[contains(@class, 'duet--content-cards--content-card')]/a")
    large_content_cards.each do |a|
      title = a["aria-label"]
      url = a["href"]
      published_at = a.parent.css(".font-normal").text.to_time
      Article.create(title: title, url: "#{news_website}#{url}", published_at: published_at)
    end

    browser.close
  end
end

