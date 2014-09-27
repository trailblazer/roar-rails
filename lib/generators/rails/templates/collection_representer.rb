module <%= class_name.pluralize %>Representer
  include Roar::Representer::<%= format %>::Collection

  items extend: <%= class_name %>Representer, class: <%= class_name %>
end
