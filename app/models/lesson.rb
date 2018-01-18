class Lesson < ApplicationRecord
  belongs_to :teacher
  belongs_to :product
  has_many :line_items
  has_many :students, through: :line_items
  has_many :line_items
  has_many :invoices, through: :line_items

  def total_price
    if self.product.package?
      total_price = self.product.price
    else
      total_price = self.product.price * self.duration
    end
    return total_price
  end

  def duration
    TimeDifference.between(self.start_date, self.end_date).in_hours
  end

  def expenses
    self.duration * 20 
  end

  def students_name
    names = []
    self.students.each do |student|
      names.push(student.name)
    end
    return names
  end

end
