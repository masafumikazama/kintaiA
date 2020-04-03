Rails.application.routes.draw do


  root 'static_pages#home'
  
  get '/signup', to: 'users#new'
  get '/working', to: 'users#working'
  get '/confirm/:id', to: 'users#confirm', as: :confirm
  
  get  '/bases', to: 'bases#show'
  post '/bases', to: 'bases#create'
  delete '/bases', to: 'bases#destroy'
  
  get  '/edit_user_info', to: 'users#edit_user_info'
  
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  get   '/edit-basic-info/:id', to: 'users#edit_basic_info', as: :basic_info
  patch 'update-basic-info', to: 'users#update_basic_info'
  
  get   'users/:id/attendances/:date/edit', to: 'attendances#edit', as: :edit_attendances
  patch 'users/:id/attendances/:date/update', to: 'attendances#update', as: :update_attendances
  
  get   'users/:id/attendances/:date/edit_edit_attendance', to: 'attendances#edit_edit_attendance', as: :edit_edit_attendance_attendances
  patch 'users/:id/attendances/:date/update_edit_attendance', to: 'attendances#update_edit_attendance', as: :update_edit_attendance_attendances
  
 # get    ':id/approval_histories',  to: 'attendances#approval_histories', as: :approval_histories_attendances
  
 # get 'users/:id/attendances/:id/edit_overwork_request', to: 'attendances#edit_overwork_request', as: :edit_overwork_request_attendances
 # patch 'users/:id/attendances/:id/update_overwork_request', to: 'attendances#update_overwork_request', as: :update_overwork_request_attendances
  
 # get 'users/:id/attendances/:id/edit_attendance_approval', to: 'attendances#edit_attendance_approval', as: :edit_attendance_approval_attendances
 # patch 'users/:id/attendances/:id/update_attendance_approval', to: 'attendances#update_attendance_approval', as: :update_attendance_approval_attendances
 
  patch 'users/:id/update-user-info', to: 'users#update_user_info', as: :update_user_info
  
  resources :users do
    
    collection do
     
      
    end
    
    member do
        get 'export'
        
        get 'edit_overwork_request'
        patch 'update_overwork_request'
        
        get 'edit_overwork_approval'
        patch 'update_overwork_approval'
        
        get 'edit_attendance_approval'
        patch 'update_attendance_approval'
        
        get 'edit_superior_approval'
        patch 'update_superior_approval'
        
        get 'edit_month_approval'
        patch 'attendances/month_approval'
        
      #  get 'confirm'
        
        get 'approval_histories'
        patch 'show_approval_histories'
        
        patch 'update_user_info'
        
        get 'attendances/edit_overwork_approval'
        patch 'attendances/update_overwork_approval'
        
        get 'attendances/edit_attendance_approval'
        patch 'attendances/update_attendance_approval'
        
        get 'attendances/edit_superior_approval'
        patch 'attendances/update_superior_approval'
        
        get 'attendances/approval_histories'
        post 'attendances/approval_histories'
        get 'attendances/show_approval_histories'
        post 'attendances/show_approval_histories'
    end
    
    collection { post :import }
    resources :attendances, only: :create
     
  end
  
  resources :bases
  
  resources :attendances do
    collection do
      get 'approval_histories'
      post 'approval_histories'
    end  
  end  

end

 