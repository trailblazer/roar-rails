<% module_namespacing do -%>
module <%= class_name %>Representer
  include Roar::Representer::<%= format %>
  <% property_options.each do |property| %>
  <%= property -%>
  <% end %>
end
<% end -%>
