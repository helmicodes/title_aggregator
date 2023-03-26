class Article < ApplicationRecord
  validates :title, uniqueness: true
  validates :url, uniqueness: true
end
