module <%= class_name %>Representer
  include Roar::<%= format %>
  <% property_options.each do |property| %>
  <%= property -%>
  <% end %>
end
