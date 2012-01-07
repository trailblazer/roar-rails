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

Note: In order to use the URL helpers you need to configure a host name in your environment.

```ruby
config.representer.default_url_options = {:host => "www.apotomo.de"}
```

### Testing

### Autoloading

Put your representers in `app/representers` and they will be autoloaded by Rails. Also, frequently used modules as media representers and features don't need to be required manually. 


## Contributors

* [Railslove](http://www.railslove.de) and especially Michael Bumann [bumi] have heavily supported development of roar-rails ("resource :singers"). 
