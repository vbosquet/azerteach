class Teacher < ApplicationRecord
  has_many :lessons
  has_many :expense_exports

  def name
    [self.firstname, self.lastname].compact.join(' ')
  end

  def address_line_1
    [self.street, self.street_number, self.box].compact.join(' ')
  end

  def address_line_2
    [self.zipcode, self.city].compact.join(' ')
  end
end
