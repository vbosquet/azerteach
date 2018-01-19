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
    get 'invoice/update_lessons_select' => "invoices#update_lessons_select"
    get 'invoice/calculate_total_amount' => "invoices#calculate_total_amount"
    get 'send_invoice/:id' => "invoices#send_invoice", as: "send_invoice"
    resources :expense_exports
    get 'expense_export/update_lessons_select' => "expense_exports#update_lessons_select"
    get 'expense_export/calculate_total_amount' => "expense_exports#calculate_total_amount"
    get 'send_expense_export/:id' => "expense_exports#send_expense_export", as: "send_expense_export"
  end  
end