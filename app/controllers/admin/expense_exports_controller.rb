# coding: utf-8

class Admin::ExpenseExportsController < Admin::AdminController
  
  def index
    @expense_exports = ExpenseExport.all
  end
  
  def show
    @expense_export = ExpenseExport.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'expense_export.pdf', template: 'admin/expense_exports/expense_export.pdf.erb', locals: {expense_export: @expense_export}
      end
    end
  end
  
  def new
    @expense_export = ExpenseExport.new
    @lessons = Lesson.where("expense_export_id IS NULL and teacher_id IS NOT NULL")
  end
  
  def create
    @expense_export = ExpenseExport.new(expense_export_params)
    if @expense_export.save
      @expense_export.generate_pdf
      redirect_to admin_expense_exports_url, :notice => "Note de frais ajoutée avec succès."
    else
      render 'new'
    end
  end
  
  def edit
    @expense_export = ExpenseExport.find(params[:id])
    @lessons = Lesson.where('teacher_id = ? and (expense_export_id IS NULL or expense_export_id = ?)', @expense_export.teacher_id, @expense_export.id)
  end
  
  def update
    @expense_export = ExpenseExport.find(params[:id])
    if @expense_export.update_attributes(expense_export_params)
      @expense_export.generate_pdf if @expense_export.sending_date.nil?
      redirect_to admin_expense_exports_url, :notice => "Note de frais modifiée avec succès."
    else
      render 'edit'
    end    
  end
  
  def destroy
    expense_export = ExpenseExport.find(params[:id])
    expense_export.lessons.each do |lesson|
      lesson.expense_export_id = nil
      lesson.save
    end
    expense_export.destroy
    head :ok
  end

  def update_lessons_select
    teacher = Teacher.find_by(id: params[:teacher_id])

    if params[:expense_export_id] != "undefined"
      @lessons = teacher.lessons.where('lessons.expense_export_id IS NULL or lessons.expense_export_id = ?', params[:expense_export_id])
    else
      @lessons = teacher.lessons.where('lessons.expense_export_id IS NULL')
    end

    @products = Product.where('id IN(?)', @lessons.map(&:product_id))
    render json: {lessons: @lessons, products: @products}
  end

  def calculate_total_amount
    @lessons = Lesson.where('id IN(?)', params[:lesson_ids])
    @total_amount = 0
    @lessons.each do |lesson|
      @total_amount += lesson.expenses
    end
    render json: {total_amount: @total_amount}
  end

  def send_expense_export
    @expense_export = ExpenseExport.find(params[:id])
    if @expense_export.update_attributes(sending_date: Date.today)
      ExpenseExportMailer.send_expense_export(@expense_export).deliver
      flash[:notice] = 'Note de frais envoyée avec succès.'
    else
      flash[:error] = "Impossible d'envoyer la note de frais. Veuillez réessayer."
    end
    redirect_to admin_expense_exports_url
  end

private

  def expense_export_params
    params.require(:expense_export).permit!
  end

end