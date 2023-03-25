class ArticlePublishedAtScraperJob < ApplicationJob
  queue_as :default

  def perform(article)
    content_url = article.url
    browser = Watir::Browser.new(:chrome, headless: true)
    browser.goto(content_url)
    content_page = Nokogiri::HTML.parse(browser.html)
    time_element = content_page.at("time")
    published_at = time_element.key?("datetime") ? time_element["datetime"] : nil
    article.update(published_at: published_at)
    browser.close
  end
end