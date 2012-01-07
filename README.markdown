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
To get the hyperlinks up and running, please make sure to set the right _host name_ in your environment files (config/environments):

```ruby
config.representer.default_url_options = {:host => "127.0.0.1:3000"}
```
### Testing

### Autoloading




## Contributors

* [Railslove](http://www.railslove.de) and especially Michael Bumann [bumi] have heavily supported development of roar-rails ("resource :singers"). 
