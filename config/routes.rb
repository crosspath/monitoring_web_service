Rails.application.routes.draw do
  root 'pages#heartbeat'
  resources :news
end
