<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action :set_<%= singular_table_name %>, only: [:show, :edit, :update, :destroy]

  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>

    respond_with @<%= plural_table_name %>, :represent_with => <%= controller_class_name %>Representer
  end

  def show
    respond_with @<%= singular_table_name %>, :represent_with => <%= class_name %>Representer
  end

  def create
    @<%= singular_table_name %> = consume! <%= class_name %>.new, represent_with: <%= class_name %>Representer
    @<%= singular_table_name %>.save

    respond_with @<%= singular_table_name %>, :represent_with => <%= class_name %>Representer
  end

  def update
    consume! @<%= class_name %>, :represent_with => <%= class_name %>Representer
    @<%= class_name %>.save

    respond_with @<%= class_name %>, :represent_with => <%= class_name %>Representer
  end

  def destroy
    @<%= orm_instance.destroy %>

    head :no_content
  end

  private

  def set_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  def <%= "#{singular_table_name}_params" %>
    <%- if attributes_names.empty? -%>
    params[<%= ":#{singular_table_name}" %>]
    <%- else -%>
    params.require(<%= ":#{singular_table_name}" %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
    <%- end -%>
  end
end
<% end -%>
