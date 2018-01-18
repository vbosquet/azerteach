# coding: utf-8

class Admin::InvoicesController < Admin::AdminController
  
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
    @lessons = Lesson.joins(:line_items).where('line_items.paid = ? and line_items.invoice_id IS NULL', false).distinct
  end
  
  def create
    @invoice = Invoice.new(invoice_params)
    @lessons = Lesson.joins(:students, :line_items).where('line_items.paid = ? and line_items.invoice_id IS NULL and students.id = ?', false, params[:invoice][:student_id]).distinct
    if params[:lesson_ids].present?
      @lessons = @lessons.where('lessons.id IN (?)', params[:lesson_ids])
    end
    if @invoice.save
      @lessons.each do |lesson|
        line_item = LineItem.find_by(lesson_id: lesson.id, student_id: params[:invoice][:student_id])
        if line_item.present?
          line_item.update_attributes(invoice_id:  @invoice.id)
        end
      end
      @invoice.generate_pdf
      redirect_to admin_invoices_url, :notice => 'Facture ajoutée avec succès.'
    else
      render 'new'
    end
  end
  
  def edit
    @invoice = Invoice.find(params[:id])
    @lessons = Lesson.joins(:line_items).where('line_items.paid = ? and (line_items.invoice_id IS NULL or line_items.invoice_id = ?)', false, @invoice.id).distinct
    @selected_lessons = @invoice.lessons
  end
  
  def update
    @invoice = Invoice.find(params[:id])
    if @invoice.update_attributes(invoice_params)

      if params[:lesson_ids].present?
        @invoice.update_line_items(params[:lesson_ids])
      elsif params[:all_lessons].present?
        @invoice.update_line_items(Lesson.joins(:line_items)
          .where('line_items.paid = ? and (line_items.invoice_id IS NULL or line_items.invoice_id = ?)', false, @invoice.id)
          .distinct.map(&:id))
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
    invoice.line_items.each do |item|
      item.invoice_id = nil
      item.save
    end
    invoice.destroy
    head :ok
  end

  def update_lessons_select
    student = Student.find_by_id(params[:student_id])

    if params[:invoice_id] != "undefined"
      @invoice = Invoice.find(params[:invoice_id])
    end

    if @invoice.present? && @invoice.student_id == student.id
      @lessons = student.lessons.joins(:line_items).where('line_items.paid = ? and (line_items.invoice_id IS NULL or line_items.invoice_id = ?)', false, @invoice.id).distinct
      @selected_lessons = @invoice.lessons
    else
      @lessons = student.lessons.joins(:line_items).where('line_items.paid = ? and line_items.invoice_id IS NULL', false).distinct
    end

    @products = Product.where('id IN(?)', @lessons.map(&:product_id))
    render json: {lessons: @lessons, products: @products, selected_lessons: (@selected_lessons if @selected_lessons.present?)}
  end

  def calculate_total_amount
    @lessons = Lesson.where('id IN(?)', params[:lesson_ids])
    @total_amount = 0
    @lessons.each do |lesson|
      duration = TimeDifference.between(lesson.start_date, lesson.end_date).in_hours
      if lesson.product.package?
        price = lesson.product.price
      else
        price = lesson.product.price * duration
      end

      @total_amount += price
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