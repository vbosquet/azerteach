class Teacher < ApplicationRecord
  has_many :lessons

  def name
    [self.firstname, self.lastname].compact.join(' ')
  end
end
