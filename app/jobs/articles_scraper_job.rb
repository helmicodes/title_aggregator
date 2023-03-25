class ArticlesScraperJob < ApplicationJob
  queue_as :default

  def perform
    news_website = "https://www.theverge.com/"
    browser = Watir::Browser.new(:chrome, headless: true)
    browser.goto(news_website)
    main_page = Nokogiri::HTML.parse(browser.html)
    articles = main_page.css("h2 a")
    articles.each do |a|
      title = a.text
      next if title == "Advertiser Content" || title == "Taken for a ride"
      url = a["href"]
      article = Article.create(title: title, url: "#{news_website}#{url}")
      ArticlePublishedAtScraperJob.perform_later(article)
    end
    browser.close
  end
end