# coding: utf-8

class Admin::StudentsController < Admin::AdminController
  
  def index
    @students = Student.all
  end
  
  def show
    @student = Student.find(params[:id])
  end
  
  def new
    @student = Student.new
  end
  
  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to admin_students_url, :notice => "Elève ajouté avec succès."
    else
      render 'new'
    end
  end
  
  def edit
    @student = Student.find(params[:id])
  end
  
  def update
    @student = Student.find(params[:id])
    if @student.update_attributes(student_params)
      redirect_to admin_students_url, :notice => "Elève modifié avec succès."
    else
      render 'edit'
    end    
  end
  
  def destroy
    Student.find(params[:id]).destroy
    head :ok
  end

  def import
    if params[:file].present?
      Student.import(params[:file])
      flash[:notice] = "Elèves imortés avec succès."
    else
      flash[:error] = "Vous n'avez sélectionner aucun fichier. Veuillez réessayer."
    end
    redirect_to admin_students_url
  end

private

  def student_params
    params.require(:student).permit!
  end

end