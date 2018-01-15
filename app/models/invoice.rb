class Invoice < ApplicationRecord
  has_many :lessons
  belongs_to :student
end
