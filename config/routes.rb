Rails.application.routes.draw do
  post 'authenticate', to: 'authentication#authenticate'
  resources :tasks, only: %i[index create update destroy] do
    resources :subtasks, only: %i[index create update destroy]
  end
end
