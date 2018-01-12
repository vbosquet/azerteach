# coding: utf-8

class Admin::<%= @model_name.pluralize %>Controller < Admin::AdminController
  
  def index
    @<%= @collection %> = <%= @model_name %>.all
  end
  
  def show
    @<%= @singular %> = <%= @model_name %>.find(params[:id])
  end
  
  def new
    @<%= @singular %> = <%= @model_name %>.new
  end
  
  def create
    @<%= @singular %> = <%= @model_name %>.new(<%= @singular %>_params)
    if @<%= @singular %>.save
      redirect_to admin_<%= @collection %>_url, :notice => "<%= @singular.camelcase %> successfully added!"
    else
      render 'new'
    end
  end
  
  def edit
    @<%= @singular %> = <%= @model_name %>.find(params[:id])
  end
  
  def update
    @<%= @singular %> = <%= @model_name %>.find(params[:id])
    if @<%= @singular %>.update_attributes(<%= @singular %>_params)
      redirect_to admin_<%= @collection %>_url, :notice => "<%= @singular.camelcase %> successfully updated!"
    else
      render 'edit'
    end    
  end
  
  def destroy
    <%= @model_name %>.find(params[:id]).destroy
    head :ok
  end

private

  def <%= @singular %>_params
    params.require(:<%= @singular %>).permit!
  end

end