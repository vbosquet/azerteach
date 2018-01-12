# coding: UTF-8
class Admin::AdminController < ActionController::Base
  before_filter :authenticate_user!

  layout 'admin'
end
