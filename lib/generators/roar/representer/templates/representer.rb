module <%= class_name %>Representer
  include Roar::Representer::<%= format %>
  <% for options in properties -%>
    property <%= ":#{options}" %>
  <% end %>
end
