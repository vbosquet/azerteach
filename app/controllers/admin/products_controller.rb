# coding: utf-8

class Admin::ProductsController < Admin::AdminController
  
  def index
    @products = Product.all
  end
  
  def show
    @product = Product.find(params[:id])
  end
  
  def new
    @product = Product.new
  end
  
  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_products_url, :notice => "Type de cours ajouté avec succès."
    else
      render 'new'
    end
  end
  
  def edit
    @product = Product.find(params[:id])
  end
  
  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(product_params)
      redirect_to admin_products_url, :notice => "Type de cours modifié avec succès."
    else
      render 'edit'
    end    
  end
  
  def destroy
    Product.find(params[:id]).destroy
    head :ok
  end

private

  def product_params
    params.require(:product).permit!
  end

end