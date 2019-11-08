Rails.application.routes.draw do
  devise_for :users
  root to: 'knowledge_bases#index'

  resources :knowledge_bases do
  	resources :answers, except: [:show] do
      post 'import', on: :collection
      get 'export', on: :collection
    end
  	resources :questions
    resources :global_values, except: [:show, :index]
    resources :user_values, except: [:show, :index]
    resources :external_api_connections, except: [:show, :index]
    resources :analytics, only: [:index]
    post 'train'
    delete 'reset'
    delete 'clear_dashboard'

    get 'export'

    # Facebook webhook
    get  'webhook', to: :webhook
    post 'webhook', to: 'knowledge_bases#receive_message'
  end

  resources :tasks
  resources :knowledge_bases, param: :hash_id, only: [] do
    get 'widget'
  end

  namespace :admin do
  	resources :users do
      post 'send_reset_password_instructions'
    end
    resources :custom_loggers, only: [:index, :show]
    resources :user_sessions, only: [:index, :destroy]
  end

  mount ActionCable.server => '/cable'
end
