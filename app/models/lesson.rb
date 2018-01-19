class Lesson < ApplicationRecord
  belongs_to :teacher, optional: true
  belongs_to :product
  has_many :line_items
  has_many :students, through: :line_items
  has_many :line_items
  has_many :invoices, through: :line_items
  belongs_to :expense_export, optional: true

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
    if self.teacher.present?
      return self.duration * 20 
    else
      return 0.0
    end
  end

  def students_name
    names = []
    self.students.each do |student|
      names.push(student.name)
    end
    return names
  end

end
