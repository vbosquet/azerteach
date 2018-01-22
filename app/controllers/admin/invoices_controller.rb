# coding: utf-8

class Admin::InvoicesController < Admin::AdminController
  
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
    @lessons = Lesson.where('student_id = ? and invoice_id IS NULL or invoice_id = ?', @invoice.student_id, @invoice.id).order('invoice_date ASC')
    @selected_lessons = @invoice.lessons.order('invoice_date ASC')
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
    render json: {lessons: @lessons, selected_lessons: (@selected_lessons if @selected_lessons.present?)}
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

private

  def invoice_params
    params.require(:invoice).permit!
  end

end