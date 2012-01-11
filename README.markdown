# roar-rails

_Makes using Roar's representers in your Rails app fun._

## Features

### Rendering with #respond_with

Easily render resources using representers with the built-in responder.

```ruby
class SingersController < ApplicationController
  respond_to :json

  def show
    singer = Singer.find_by_id(params[:id])
    respond_with singer
  end

  def self.responder
    Class.new(super).send :include, Roar::Rails::Responder
  end

end
```

Need to use a representer with a different name than your model? Pass it in using the `:with_representer` option:

```ruby
class SingersController < ApplicationController
  respond_to :json

  def show
    singer = Musician.find_by_id(params[:id])
    respond_with singer, with_representer: SingerRepresenter
  end

  def self.responder
    Class.new(super).send :include, Roar::Rails::Responder
  end

end
```

Goes great with [Jose Valim's responders gem][responders]!

```ruby
class SingersController < ApplicationController
  respond_to :json

  responders Roar::Rails::Responder

  def show
    singer = Singer.find_by_id(params[:id])
    respond_with singer
  end

end
```

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

Put your representers in `app/representers` and they will be autoloaded by Rails. Also, frequently used modules as media representers and features don't need to be required manually.


## Contributors

* [Railslove](http://www.railslove.de) and especially Michael Bumann [bumi] have heavily supported development of roar-rails ("resource :singers").

[responders]: https://github.com/plataformatec/responders
