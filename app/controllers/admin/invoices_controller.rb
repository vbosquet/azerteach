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
    @lessons = Lesson.where(paid: false)
  end
  
  def create
    @invoice = Invoice.new(invoice_params)
    if @invoice.save
      redirect_to admin_invoices_url, :notice => 'Facture ajoutée avec succès.'
    else
      render 'new'
    end
  end
  
  def edit
    @invoice = Invoice.find(params[:id])
  end
  
  def update
    @invoice = Invoice.find(params[:id])
    if @invoice.update_attributes(invoice_params)
      redirect_to admin_invoices_url, :notice => 'Facture modifiée avec succès.'
    else
      render 'edit'
    end    
  end
  
  def destroy
    Invoice.find(params[:id]).destroy
    head :ok
  end

  def update_lessons_select
    @lessons = Student.find_by_id(params[:student_id]).lessons.where(paid: false)
    @products = Product.where('id IN(?)', @lessons.map(&:product_id))
    render json: {lessons: @lessons, products: @products}
  end

  def calculate_total_amount
    @lessons = Lesson.where("id IN(?)", params[:lesson_ids])
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

private

  def invoice_params
    params.require(:invoice).permit!
  end

end