# coding: utf-8

class Admin::InvoicesController < Admin::AdminController
  before_action :find_lessons, only: [:index, :generate_multiple_invoices]

  def index
    @invoices = Invoice.all
  end

  def show
    @invoice = Invoice.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'invoice.pdf', template: 'admin/invoices/invoice.pdf.erb', locals: {invoice: @invoice}
      end
    end
  end

  def new
    @invoice = Invoice.new
    @numero = increment_numero
    if params[:student_id].present?
      @student = Student.find_by_id(params[:student_id])
      @lessons = @student.lessons.where('invoice_id IS NULL').order('invoice_date ASC')
    else
      @lessons = Lesson.where('invoice_id IS NULL').order('invoice_date ASC')
    end
    @lessons = @lessons.select {|l| TimeDifference.between(l.invoice_date, Date.today).in_days > 4}
  end

  def create
    @invoice = Invoice.new(invoice_params)
    if @invoice.save

      if params[:all_lessons].present?
        @invoice.lessons.each do |lesson|
          lesson.invoice_id = @invoice.id
          lesson.save
        end
      end
      @invoice.generate_pdf
      redirect_to admin_invoices_url, :notice => 'Facture ajoutée avec succès.'
    else
      flash[:error] = @invoice.errors.full_messages
      render 'new'
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
    @student = @invoice.student
    @lessons = Lesson.where('student_id = ? and invoice_id IS NULL or invoice_id = ?', @invoice.student_id, @invoice.id).order('invoice_date ASC').select {|l| TimeDifference.between(l.invoice_date, Date.today).in_days > 4}
    @selected_lessons = @invoice.lessons.order('invoice_date ASC').select {|l| TimeDifference.between(l.invoice_date, Date.today).in_days > 4}
    @numero = @invoice.numero
  end

  def update
    @invoice = Invoice.find(params[:id])
    if @invoice.update_attributes(invoice_params)

      if params[:all_lessons].present?
        @invoice.lessons.each do |lesson|
          lesson.invoice_id = @invoice.id
          lesson.save
        end
      end

      @invoice.generate_pdf if @invoice.sending_date.nil?
      @invoice.set_payment_date if @invoice.payment_status
      redirect_to admin_invoices_url, :notice => 'Facture modifiée avec succès.'
    else
      render 'edit'
    end
  end

  def destroy
    invoice = Invoice.find(params[:id])
    invoice.lessons.each do |lesson|
      lesson.invoice_id = nil
      lesson.save
    end
    invoice.destroy
    head :ok
  end

  def update_lessons_select
    student = Student.find_by_id(params[:student_id])

    if params[:invoice_id] != "undefined"
      invoice = Invoice.find(params[:invoice_id])
    end

    if invoice.present? && invoice.student_id == student.id
      @lessons = student.lessons.where('invoice_id IS NULL or invoice_id = ?', invoice.id).order('invoice_date ASC')
      @selected_lessons = invoice.lessons.order('invoice_date ASC')
    else
      @lessons = student.lessons.where('invoice_id IS NULL').order('invoice_date ASC')
    end
    render json: {lessons: @lessons.select {|l| TimeDifference.between(l.invoice_date, Date.today).in_days > 4},
    selected_lessons: (@selected_lessons.select {|l| TimeDifference.between(l.invoice_date, Date.today).in_days > 4} if @selected_lessons.present?)}
  end

  def calculate_total_amount
    @lessons = Lesson.where('id IN(?)', params[:lesson_ids])
    @total_amount = 0
    @lessons.each do |lesson|
      if lesson.invoice_status != 'paid'
        @total_amount += (lesson.full_price - lesson.discount)
      end
    end
    render json: {total_amount: @total_amount}
  end

  def send_invoice
    @invoice = Invoice.find(params[:id])
    if @invoice.update_attributes(sending_date: Date.today)
      InvoiceMailer.send_invoice(@invoice).deliver
      flash[:notice] = 'Facture envoyée avec succès.'
    else
      flash[:error] = "Impossible d'envoyer la facture. Veuillez réessayer."
    end
    redirect_to admin_invoices_url
  end

  def generate_multiple_invoices
    if params[:billable_lessons_ids].present?
      billable_lessons = Lesson.where("id IN (?)", params[:billable_lessons_ids])
      if billable_lessons.select {|l| l.invoice.nil?}.present?
        lessons_by_student = billable_lessons.select {|l| l.invoice.nil?}.group_by { |l| l.student }
        lessons_by_student.each do |student, lessons|
          invoice = Invoice.create(numero: increment_numero, student_id: student.id,
            amount: lessons.sum {|l| l.paid? ? 0 : l.full_price - l.discount})
          lessons.each do |lesson|
            lesson.invoice_id = invoice.id
            lesson.save
          end
          invoice.generate_pdf
        end
      end
    end

    respond_to do |format|
      format.json { head :ok }
    end
  end

  def send_multiple_invoices
    if params[:invoice_ids].present?
      invoices = Invoice.where("id IN (?) and sending_date IS NULL", params[:invoice_ids])
      if invoices.present?
        invoices.all.each do |invoice|
          if invoice.update_attributes(sending_date: Date.today)
            InvoiceMailer.send_invoice(invoice).deliver_later
          end
        end
      end
    end

    respond_to do |format|
      format.json { head :ok }
    end
  end

  def send_multiple_reminders
    if params[:billed_lessons_ids].present?
      invoices = Invoice.joins(:lessons).where("lessons.id IN (?) and lessons.invoice_status != ? and invoices.first_reminder_date IS NULL", params[:billed_lessons_ids], 1).distinct
      if invoices.present?
        invoices.each do |invoice|
          if invoice.update_attributes(first_reminder_date: Date.today)
            InvoiceMailer.send_reminder_to_student(invoice).deliver_later
          end
        end
      end
    end

    respond_to do |format|
      format.json { head :ok }
    end
  end

private

  def invoice_params
    params.require(:invoice).permit!
  end

  def find_lessons
    @unpaid_lessons = Lesson.all.where("invoice_status != ?", 1).order('invoice_date ASC').select {|l| l.invoice.present? && l.invoice.sending_date.present? && TimeDifference.between(l.invoice.sending_date, Date.today).in_days > 30}
    @billed_lessons = Lesson.all.order('invoice_date ASC').select {|l| (l.invoice.present? && l.invoice.sending_date.nil?) || (l.invoice.present? && l.invoice.sending_date.present? && (TimeDifference.between(l.invoice.sending_date, Date.today).in_days <= 30 || l.invoice.payment_status))}
    @billable_lessons = Lesson.all.where('invoice_id IS NULL').order('invoice_date ASC').select {|l| TimeDifference.between(l.invoice_date, Date.today).in_days > 4}
  end

  def increment_numero
    last_numero = Invoice.last.present? ? Invoice.last.numero : "#{Time.zone.now.year}#{Time.zone.now.month}-0"
    i = last_numero.index("-")
    return "#{Time.zone.now.year}#{Time.zone.now.month}-#{last_numero[i+1..last_numero.size].to_i + 1}"
  end

end
