class Student < ApplicationRecord
  has_many :invoices
  has_many :line_items
  has_many :lessons, through: :line_items

  def address_line_1
    [self.street, self.street_number, self.box].compact.join(' ')
  end

  def address_line_2
    [self.zipcode, self.city].compact.join(' ')
  end

  def name
    [self.firstname, self.lastname].compact.join(' ')
  end
end
