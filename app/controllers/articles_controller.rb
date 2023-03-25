class ArticlesController < ApplicationController
  def index
    @articles = Article.where("published_at >= ?", "2022-01-01".to_time).order(published_at: :desc)
  end
end