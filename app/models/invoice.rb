class Invoice < ApplicationRecord
  belongs_to :student
  has_many :lessons
  #has_many :line_items
  #has_many :lessons, through: :line_items

  has_attached_file :pdf
  validates_attachment_content_type :pdf, content_type: "application/pdf"
  process_in_background :pdf

  enum invoice_status: {queued: 0, complete: 1}

  def set_payment_date
  	self.payment_date = Date.today
    self.save
    self.lessons.each do |lesson|
      lesson.invoice_status = 'paid'
      lesson.save
    end
  end

  def generate_pdf
    Delayed::Job.enqueue GeneratePdfJob.new(self)
    self.update_attribute(:status, 'queued')
  end

  def update_line_items(new_lesson_ids)
    lesson_ids = self.lessons.map(&:id)
    if lesson_ids.size > new_lesson_ids.size # remove line_items from invoice
      items = self.line_items.where('lesson_id NOT IN(?)', new_lesson_ids)
      items.each do |item|
        item.invoice_id = nil
        item.save
      end
    elsif lesson_ids.size < new_lesson_ids.size # add line_items to invoive
      items = LineItem.where("lesson_id IN(?) and student_id = ?", new_lesson_ids, self.student_id)
      items.each do |item|
        item.invoice_id = self.id
        item.save
      end
    end
  end

end
