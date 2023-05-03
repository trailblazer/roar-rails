class <%= class_name %>Representer < Roar::Decorator
  include Roar::Representer::<%= format %>
  <% property_options.each do |property| %>
  <%= property -%>
  <% end %>
end
