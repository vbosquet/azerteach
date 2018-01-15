class Lesson < ApplicationRecord
  belongs_to :student
  belongs_to :teacher
  belongs_to :product
  belongs_to :invoice, optional: true
end
