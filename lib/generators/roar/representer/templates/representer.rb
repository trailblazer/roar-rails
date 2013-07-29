module <%= class_name %>Representer
  <% for options in properties -%>
    property <%= ":#{options}" %>
  <% end %>
end
