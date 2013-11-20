Chapter2App::Application.routes.draw do
    
  # enable routing based on users resource
  # HTTP Request  URL           Action    Named Route           Purpose
  # ------------  ---------     --------- --------------------  --------------
  # GET           /users        index     users_path            page to list all users
  # GET           /users/1      show      user_path(user)       page to show user
  # GET           /users/new    new       new_user_path         page to make a new user (signup)
  # POST          /users        create    users_path            create a new user
  # GET           /users/1/edit edit      edit_user_path(user)  page to edit user with id 1
  # PATCH         /users/1      update    user_path(user)       update user
  # DELETE        /users/1      destroy   user_path(user)       delete user
  resources :users
  
  # routing for sessions, note only new, create, destroy actions
  # HTTP Request  URL           Action    Named Route           Purpose
  # ------------  ---------     --------- --------------------  --------------
  # GET           /signin       new       signin_path           page for a new session (signin)
  # POST          /sessions     create    sessions_path         create a new session
  # DELETE        /signout      destroy   signout_path          delete a session (sign out)
  resources :sessions, only: [:new, :create, :destroy]
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  
  # Home Page Routing
  root 'static_pages#home'
  
  # Static Page Routing to "static_pages" controller
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  
  # signup URL for new users
  match "/signup",  to: 'users#new',            via: 'get'
  
  # routing for Salesforce powered Product Catalogue
  root :to => "products#index"
  resources :products
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
