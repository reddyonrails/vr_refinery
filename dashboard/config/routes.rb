::Refinery::Application.routes.draw do
  scope(:path => 'refinery',  :module => 'admin') do
    match 'dashboard',
          :to => 'dashboard#index',
          :as => :dashboard

    match 'disable_upgrade_message',
          :to => 'dashboard#disable_upgrade_message',
          :as => :disable_upgrade_message
  end
end
