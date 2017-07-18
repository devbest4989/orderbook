Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'plainpage#index'
  get '/product_types' => 'plainpage#product_type'
  get '/product_list' => 'plainpage#product_list'
  get '/product_cat' => 'plainpage#product_cat'
  get '/product_line' => 'plainpage#product_line'
  get '/product_brand' => 'plainpage#product_brand'
  get '/order_list' => 'plainpage#order_list'
  get '/order_new' => 'plainpage#order_new'

  #Configure Pane
  get '/config_company' => 'plainpage#config_company'
  get '/config_users' => 'plainpage#config_users'
  get '/config_tax' => 'plainpage#config_tax'
  get '/config_price' => 'plainpage#config_price'
  get '/config_format' => 'plainpage#config_format'
  get '/config_station' => 'plainpage#config_station'
  get '/config_email' => 'plainpage#config_email'
  get '/config_warehouse' => 'plainpage#config_warehouse'
  get '/config_shipping_method' => 'plainpage#shipping_method'
  get '/config_payment_term' => 'plainpage#config_payment_term'

  put '/edit_config_company' => 'plainpage#edit_config_company'

  get '/preview_invoice/:token' => 'preview#invoice', as: 'preview_invoice'

  # Ajax Controller
  post '/smart_search' => 'plainpage#smart_search', :defaults => { :format => 'json' }

  devise_for :users

  resources :users do
    collection do
      put :update_password
      put :update_info
      put :update_avatar
      post :list
      post :change
      post :append
    end
  end

  get '/customers/bill_state' => 'customers#bill_state'
  get '/customers/ship_state' => 'customers#ship_state'
  post '/customer/detail_info/:id' => 'customers#detail_info', :defaults => { :format => 'json' }  

  resources :customers do
    member do
      put :update_document
      put :update_contact
    end
  end

  get '/suppliers/bill_state' => 'suppliers#bill_state'
  get '/suppliers/ship_state' => 'suppliers#ship_state'
  resources :suppliers do
    member do
      put :update_document
      put :update_contact
    end
  end

  resources :documents
  resources :contacts do
    member do
      get :remove, :defaults => { :format => 'json' }
    end
  end

  resources :sales_orders do
    member do
      post :update_status
      post :book
      post :cancel
      post :return
      post :ship
      post :pack
      post :invoice
      post :get_invoice
      post :remove_activity
      post :print, :defaults => { :format => 'pdf' }
      post :pack_pdf, :defaults => { :format => 'pdf' }
      post :ship_pdf, :defaults => { :format => 'pdf' }
    end

    collection do
      get  ':type/list_orders', to: 'sales_orders#list_by_type', as: 'list_by_type'
    end
  end

  resources :taxes do
    collection do
      post :list
      post :remove
      post :change
      post :append
    end
  end

  resources :payment_terms do
    collection do
      post :list
      post :remove
      post :change
      post :append
    end
  end

  resources :shipping_methods do
    collection do
      post :list
      post :remove
      post :change
      post :append
    end
  end

  resources :warehouses do
    collection do
      post :list
      post :remove
      post :change
      post :append
    end
  end

  resources :brands do
    collection do
      post :list
      post :remove
      post :change
      post :append
      post :list_option
    end
  end

  resources :categories do
    collection do
      post :list
      post :remove
      post :change
      post :append
      post :list_option
    end
  end

  resources :product_lines do
    collection do
      post :list
      post :remove
      post :change
      post :append
      post :list_option
    end
  end

  resources :products do
    collection do
      post :list
      post :remove
      post :change
      post :append
      post :list_by_sku
      post :list_by_name
      post :list_by_id
      post :bulk_action
      get  ':type/list_products', to: 'products#list_by_type', as: 'list_by_type'
      get  :upload
      post :upload_file
      get  :download
    end
    member do
      get  :action
    end
  end

  resources :invoices do
    member do
      post :generate_pdf, :defaults => { :format => 'pdf' }
      post :print
      post :mail
      post :add_payment, :defaults => { :format => 'json' }
      post :approve
    end

    collection do
      get  ':type/list_invoices', to: 'invoices#list_by_type', as: 'list_by_type'      
    end
  end


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
