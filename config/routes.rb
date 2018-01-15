Rails.application.routes.draw do

  devise_for :users
  root to: 'admin/dashboard#index'
  
  namespace :admin do
    root to: 'dashboard#index'
    resources :users
    resources :students
    resources :teachers
    resources :products
    resources :lessons
    resources :invoices
    get 'update_lessons_select' => "invoices#update_lessons_select"
    get 'calculate_total_amount' => "invoices#calculate_total_amount"
  end  
end