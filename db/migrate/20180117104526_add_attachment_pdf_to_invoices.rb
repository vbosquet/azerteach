class AddAttachmentPdfToInvoices < ActiveRecord::Migration[5.1]
  def self.up
    change_table :invoices do |t|
      t.attachment :pdf
    end
  end

  def self.down
    remove_attachment :invoices, :pdf
  end
end
