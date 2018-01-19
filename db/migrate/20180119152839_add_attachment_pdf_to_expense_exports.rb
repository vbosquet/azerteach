class AddAttachmentPdfToExpenseExports < ActiveRecord::Migration[5.1]
  def self.up
    change_table :expense_exports do |t|
      t.attachment :pdf
    end
  end

  def self.down
    remove_attachment :expense_exports, :pdf
  end
end
