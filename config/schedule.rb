every 2.minutes do
  runner "Article.delete_all"
  runner "ArticlesScraperJob.perform_now"
end
