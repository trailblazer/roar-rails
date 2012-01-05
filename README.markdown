# roar-rails

_Makes using Roar's representers in your Rails app fun._

## Features

### URL Helpers

Any URL helpers from the Rails app are automatically available in representers.

```ruby
module FruitRepresenter
  include Roar::Representer::JSON
  
  link :self do
    fruit_url self
  end
```

### Testing

### Autoloading




## Contributors

* [Railslove](http://www.railslove.de) and especially Michael Bumann [bumi] have heavily supported development of roar-rails ("resource :singers"). 
