Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  mount MissionControl::Jobs::Engine, at: "/jobs"

  scope "/control_master", controller: :control_master do
    post :connect, as: :connect_control_master
    post :disconnect, as: :disconnect_control_master
  end

  scope "/vpn", controller: :vpn do
    post :connect, as: :connect_vpn
  end

  scope "/dependency_updates", controller: :dependency_updates do
    post :merge_all, as: :merge_all_dependency_updates
    post :release_all, as: :release_all_dependency_updates
  end

  root "dashboard#index"
  resources :deployments, only: [ :index ]
  resources :integration_tests, only: [ :index, :show ] do
    collection { post :run }
    member     { post :run }
  end
end
