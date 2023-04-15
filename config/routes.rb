Rails.application.routes.draw do
  resources :articles, only: %i[index create]
  root "articles#index"
end
