# coding: utf-8

class Admin::InvoicesController < Admin::AdminController
  before_action :find_lessons, only: [:index, :generate_multiple_invoices]
  
  def index
    @invoices = Invoice.all
  end
  
  def show
    @invoice = Invoice.find(params[:id])
  end
  
  def new
    @invoice = Invoice.new
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
    if @billable_lessons.select {|l| l.invoice.nil?}.present?
      lessons_by_student = @billable_lessons.select {|l| l.invoice.nil?}.group_by { |l| l.student }
      lessons_by_student.each do |student, lessons|
        invoice = Invoice.new
        last_numero = Invoice.last.present? ? Invoice.last.numero.to_i : 1
        invoice.numero =  last_numero + 1
        invoice.student_id = student.id
        invoice.amount = lessons.sum {|l| l.paid? ? 0 : l.full_price - l.discount}
        invoice.save
        lessons.each do |lesson|
          lesson.invoice_id = invoice.id
          lesson.save
        end
        invoice.generate_pdf
      end
    end
    redirect_to admin_invoices_url
  end

  def send_multiple_invoices
    @invoices = Invoice.all.where("sending_date IS NULL")
    if @invoices.present? 
      @invoices.all.each do |invoice|
        if invoice.update_attributes(sending_date: Date.today)
          InvoiceMailer.send_invoice(invoice).deliver
        end
      end
      flash[:notice] = "Factures envoyées avec succès."
    end
    redirect_to admin_invoices_url
  end

private

  def invoice_params
    params.require(:invoice).permit!
  end

  def find_lessons
    @billable_lessons = Lesson.all.where('invoice_id IS NULL or id IN (?)', Lesson.all.joins(:invoice).where('lessons.invoice_id IS NOT NULL and invoices.sending_date IS NULL').distinct.map(&:id)).order('invoice_date ASC').select {|l| TimeDifference.between(l.invoice_date, Date.today).in_days > 4}
  end

end