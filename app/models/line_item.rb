class LineItem < ApplicationRecord
	belongs_to :lesson
	belongs_to :student
	belongs_to :invoice, optional: true
end
