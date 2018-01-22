class Student < ApplicationRecord
  has_many :invoices
  has_many :lessons
  #has_many :line_items
  #has_many :lessons, through: :line_items

  def address_line_1
    [self.street, self.street_number, self.box].compact.join(' ')
  end

  def address_line_2
    [self.zipcode, self.city].compact.join(' ')
  end

  def name
    [self.firstname, self.lastname].compact.join(' ')
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      insert_students(row)
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::Csv.new(file.path)
    when '.xls' then Roo::Excel.new(file.path)
    when '.xlsx' then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.insert_students(row)
    student = Student.find_by_code(row["Client ID"])
    if student.nil?
      student = Student.new
      student.code = row["Client ID"]
    end
    student.firstname = row["First Name"]
    student.lastname = row["Last Name"]
    student.email = row["Email"]
    student.birthdate = row["Date of Birth"]
    student.phone_number = row["Telephone"]
    student.mobile = row["Mobile Number"]
    student.save!
  end

end
