<% module_namespacing do -%>
module <%= class_name.pluralize %>Representer
  include Representable::JSON::Collection

  items extend: <%= class_name %>Representer, class: <%= class_name %>
end
<% end %>
