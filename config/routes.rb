TweetLead::Application.routes.draw do
  get "home/index"

  resources :searches

  resources :keywords

  resources :responses

  resources :sheduled_messages

  resources :accounts

  resources :tweets

  resources :profiles

  resources :searches_results

  match "/auth/twitter/callback" => "accounts#save_tokens"
  
  match '/extract_mentions' => 'tweets#extract_mentions'
  
  match '/get_all_timeline' => 'accounts#get_all_timeline'
  
  match '/send' => 'sheduled_messages#send_messages'
  
  match '/process_searches' => 'searches#process_all'
  
 match '/launch_senders' => 'searches#launch_senders'
  
 match '/accounts/:id/follow/:user' => 'accounts#follow', :as => :follow


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'profiles#to_reply'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
