class ArticlesController < ApplicationController
  def index
    @articles = Article.where("published_at >= ?", "2022-01-01".to_time).order(published_at: :desc)
  end

  def create
    ArticlesScraperJob.perform_later
    redirect_to articles_path
  end
end