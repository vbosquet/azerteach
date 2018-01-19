# coding: UTF-8
class Admin::DashboardController < Admin::AdminController
  
  def index
  	@turnover = Lesson.all.sum {|l| l.total_price * l.students.count}
  	@unpaids = LineItem.where("line_items.paid = ?", false).sum {|l| l.lesson.product.price}
  	@expenses = Lesson.all.sum {|l| l.expenses}
  end
  
end