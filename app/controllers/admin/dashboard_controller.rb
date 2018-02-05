# coding: UTF-8
class Admin::DashboardController < Admin::AdminController

  def index
  	@turnover = Lesson.all.sum {|l| l.full_price - l.discount}
  	@unpaids = Lesson.where("invoice_status != ?", 1).sum {|l| l.full_price - l.discount}
  end

end
