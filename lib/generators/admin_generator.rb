class AdminGenerator < Rails::Generators::Base
  
  argument :name, :required => true
  argument :fields, :type => :array, :default => []
  
  def create_admin_files
    @singular = name.singularize
    @model_name = @singular.camelcase
    @collection = @singular.pluralize
    @keys = fields
    
    template('controllers/admin_controller.rb', "app/controllers/admin/#{@collection}_controller.rb")
    
    template('views/index.html.erb', "app/views/admin/#{@collection}/index.html.erb")
    template('views/new.html.erb', "app/views/admin/#{@collection}/new.html.erb")
    template('views/edit.html.erb', "app/views/admin/#{@collection}/edit.html.erb")
    template('views/_form.html.erb', "app/views/admin/#{@collection}/_form.html.erb")    
  end
end