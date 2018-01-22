# coding: utf-8

class Admin::LessonsController < Admin::AdminController
  
  def index
    @lessons = Lesson.all
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
    not_included = @lesson.check_invoice_presence_before_update(params[:lesson][:student_ids])

    unless not_included.empty?
      flash[:error] = "Vous ne pouvez pas retirez les utilisateurs suivants : #{Student.where('id IN (?)', not_included).map {|s| s.name}.join(', ')}"
      render "edit"
    end and return

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

private

  def lesson_params
    params.require(:lesson).permit!
  end

end