class Lesson < ApplicationRecord
  belongs_to :teacher, optional: true
  belongs_to :product, optional: true
  belongs_to :student, optional: true
  belongs_to :invoice, optional: true
  #has_many :line_items
  #has_many :students, through: :line_items
  #has_many :line_items
  #has_many :invoices, through: :line_items
  #belongs_to :expense_export, optional: true

  enum invoice_status: {unpaid: 0, paid: 1, part_paid: 2}

  #def total_price
    #if self.product.package?
      #total_price = self.product.price
    #else
      #total_price = self.product.price * self.duration
    #end
    #return total_price
  #end

  #def duration
    #TimeDifference.between(self.start_date, self.end_date).in_hours
  #end

  #def expenses
    #if self.teacher.present?
      #return self.duration * 20
    #else
      #return 0.0
    #end
  #end

  #def students_name
    #names = []
    #self.students.each do |student|
      #names.push(student.name)
    #end
    #return names
  #end

  #def check_invoice_presence_before_update(new_student_ids)
    #student_ids = self.invoices.map(&:student_id)
    #not_included = []
    #student_ids.each do |id|
      #if !new_student_ids.include?(id.to_s)
        #not_included.push(id)
      #end
    #end
  #end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      if row["Client ID"].present? && row["Client ID"] != '' && row["Invoice Date"].present?
        insert_lessons(row)
      elsif row["Duration"].present?
        insert_duration(row)
      end
    end
  end

  def self.insert_duration(row)
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::Csv.new(file.path)
    when '.xls' then Roo::Excel.new(file.path)
    when '.xlsx' then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.insert_lessons(row)
    lesson = Lesson.find_by_code(row["Item ID"])
    if lesson.nil?
      lesson = Lesson.new
      lesson.code = row["Item ID"]
    end
    lesson.teacher_name = row["Staff Member"]
    lesson.item_sold = row["Item Sold"]
    lesson.item_group = row["Item Group"]
    lesson.full_price = row["Item Full Price"]
    lesson.discount = row["Discount Amount"]
    lesson.invoice_date = row["Invoice Date"]
    lesson.invoice_number = row["Invoice Number"]
    lesson.invoice_status = set_status(row["Invoice Status"])
    student = Student.find_by_code(row["Client ID"])
    lesson.student_id = student.id if student.present?
    lesson.save!
  end

  def self.insert_duration(row)
    student_name = row["Client"]
    teacher_name = row["Staff"]
    date = row["Scheduled Date"]
    price = row["Price"]
    duration = row["Duration"]
    if date.present? && price.present? && teacher_name.present? && student_name.present?
      lessons = Lesson.where("invoice_date = ? and full_price = ? and teacher_name = ?", date, price, teacher_name).select {|l| l.student.name == student_name}
      if lessons.present?
        lessons.each do |lesson|
          lesson.duration = duration
          lesson.save
        end
      end
    end
  end

  def self.set_status(status)
    case status
      when "Paid"
        return invoice_status = "paid"
      when "Unpaid"
        return invoice_status = "unpaid"
      when "Part Paid"
        return "part_paid"
    end
  end

  def get_payment_status
    case self.invoice_status
      when "paid"
        return "Payé"
      when "unpaid"
        "Impayé"
      when "part_paid"
        "Partiellement payé"
      end
  end

end
