<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  include Roar::Rails::ControllerAdditions
  respond_to :json

  before_action :set_<%= singular_table_name %>, only: [:show, :edit, :update, :destroy]

  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>

    respond_with @<%= plural_table_name %>, :represent_with => <%= controller_class_name %>Representer
  end

  def show
    respond_with @<%= singular_table_name %>, :represent_with => <%= class_name %>Representer
  end

  def create
    @<%= singular_table_name %> = consume! <%= class_name %>.new, :represent_with => <%= class_name %>Representer
    @<%= singular_table_name %>.save

    respond_with @<%= singular_table_name %>, :represent_with => <%= class_name %>Representer
  end

  def update
    consume! @<%= singular_table_name %>, :represent_with => <%= class_name %>Representer
    @<%= singular_table_name %>.save

    respond_with @<%= singular_table_name %>, :represent_with => <%= class_name %>Representer
  end

  def destroy
    @<%= orm_instance.destroy %>

    head :no_content
  end

  private

  def set_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end
end
<% end -%>
