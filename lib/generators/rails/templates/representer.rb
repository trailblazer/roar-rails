module <%= class_name %>Representer
<% if format == 'JSON::JsonApi' %>
  include Roar::JSON::JsonApi
<% else %>
  include Roar::Representer::<%= format %>
<% end %>
  <% property_options.each do |property| %>
  <%= property -%>
  <% end %>
end
