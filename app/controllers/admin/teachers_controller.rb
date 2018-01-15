# coding: utf-8

class Admin::TeachersController < Admin::AdminController
  
  def index
    @teachers = Teacher.all
  end
  
  def show
    @teacher = Teacher.find(params[:id])
  end
  
  def new
    @teacher = Teacher.new
  end
  
  def create
    @teacher = Teacher.new(teacher_params)
    if @teacher.save
      redirect_to admin_teachers_url, :notice => "Professeur ajouté avec succès."
    else
      render 'new'
    end
  end
  
  def edit
    @teacher = Teacher.find(params[:id])
  end
  
  def update
    @teacher = Teacher.find(params[:id])
    if @teacher.update_attributes(teacher_params)
      redirect_to admin_teachers_url, :notice => "Professeur modifié avec succès."
    else
      render 'edit'
    end    
  end
  
  def destroy
    Teacher.find(params[:id]).destroy
    head :ok
  end

private

  def teacher_params
    params.require(:teacher).permit!
  end

end