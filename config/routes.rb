Rails.application.routes.draw do

  devise_for :users
  root to: 'admin/dashboard#index'
  
  namespace :admin do
    root to: 'dashboard#index'
    resources :users
    resources :students do
      collection { post :import }
    end
    resources :teachers
    resources :products
    resources :lessons do
      collection { post :import }
    end
    resources :invoices
    get 'invoice/update_lessons_select' => "invoices#update_lessons_select"
    get 'invoice/calculate_total_amount' => "invoices#calculate_total_amount"
    get 'send_invoice/:id' => "invoices#send_invoice", as: "send_invoice"
  end  
end