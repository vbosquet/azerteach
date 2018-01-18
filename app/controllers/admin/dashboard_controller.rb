# coding: UTF-8
class Admin::DashboardController < Admin::AdminController
  
  def index
  	@turnover = Lesson.all.sum {|l| l.total_price * l.students.count}
  	@unpaids = Lesson.joins(:line_items).where("line_items.paid = ?", false).distinct.sum {|l| l.total_price * l.students.count}
  	@expenses = Lesson.all.sum {|l| l.expenses}
  end
  
end