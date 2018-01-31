# coding: utf-8

class Admin::LessonsController < Admin::AdminController
  before_action :find_lessons, only: [:index]
  
  def index
  end
  
  def show
    @lesson = Lesson.find(params[:id])
  end
  
  def new
    @lesson = Lesson.new
  end
  
  def create
    @lesson = Lesson.new(lesson_params)
    if @lesson.save
      redirect_to admin_lessons_url, :notice => "Réservation ajoutée avec succès."
    else
      render 'new'
    end
  end
  
  def edit
    @lesson = Lesson.find(params[:id])
  end
  
  def update
    @lesson = Lesson.find(params[:id])
    #not_included = @lesson.check_invoice_presence_before_update(params[:lesson][:student_ids])

    #unless not_included.empty?
      #flash[:error] = "Vous ne pouvez pas retirez les utilisateurs suivants : #{Student.where('id IN (?)', not_included).map {|s| s.name}.join(', ')}"
      #render "edit"
    #end and return

    if @lesson.update_attributes(lesson_params)
      redirect_to admin_lessons_url, :notice => "Réservation modifiée avec succès."
    else
      render 'edit'
    end    
  end
  
  def destroy
    Lesson.find(params[:id]).destroy
    head :ok
  end

  def import
    if params[:file].present?
      Lesson.import(params[:file])
      flash[:notice] = "Réservations importées avec succès."
    else
      flash[:error] = "Vous n'avez sélectionner aucun fichier. Veuillez réessayer."
    end
    redirect_to admin_lessons_url
  end

private

  def lesson_params
    params.require(:lesson).permit!
  end

  def find_lessons
    @unpaid_lessons = Lesson.all.where("invoice_status != ?", 1).order('invoice_date ASC').select {|l| l.invoice.present? && l.invoice.sending_date.present? && TimeDifference.between(l.invoice.sending_date, Date.today).in_days > 30}
    @billed_lessons = Lesson.all.order('invoice_date ASC').select {|l| l.invoice.present? && l.invoice.sending_date.present? && (TimeDifference.between(l.invoice.sending_date, Date.today).in_days <= 30 || l.invoice.payment_status)}
    @billable_lessons = Lesson.all.where('invoice_id IS NULL or id IN (?)', Lesson.all.joins(:invoice).where('lessons.invoice_id IS NOT NULL and invoices.sending_date IS NULL').distinct.map(&:id)).order('invoice_date ASC').select {|l| TimeDifference.between(l.invoice_date, Date.today).in_days > 4}
  end

end