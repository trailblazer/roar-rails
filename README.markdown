# roar-rails

_Makes using Roar's representers in your Rails app fun._

## Features

* Rendering with responders
* Parsing incoming documents
* URL helpers in representers
* Better tests
* Autoloading

## Rendering with #respond_with

Easily render resources using representers with the built-in responder.

```ruby
class SingersController < ApplicationController
  include Roar::Rails::ControllerAdditions
  respond_to :json

  def show
    singer = Singer.find_by_id(params[:id])
    respond_with singer
  end
end
```

Need to use a representer with a different name than your model? Pass it in using the `:represent_with` option:

```ruby
class SingersController < ApplicationController
  include Roar::Rails::ControllerAdditions
  respond_to :json

  def show
    singer = Musician.find_by_id(params[:id])
    respond_with singer, :represent_with => SingerRepresenter
  end
end
```

If you don't want to write a dedicated representer for a collection of items (highly recommended, thou) but rather use a representer for each item, use the `+represent_items_with+` option.

```ruby
class SingersController < ApplicationController

  def index
    singers = Musician.find(:all)
    respond_with singers, :represent_items_with => SingerRepresenter
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


## Parsing incoming documents

In `#create` and `#update` actions it is often necessary to parse the incoming representation and map it to a model instance. Use the `#consume!` method for this.

```ruby
class SingersController < ApplicationController
  respond_to :json

  def create
    singer = Singer.new
    consume!(singer)
    
    respond_with singer
  end
end
```

The `consume!` call will roughly do the following.

```ruby
singer.
  extend(SingerRepresenter)
  from_json(request.body)
```

So, `#consume!` helps you figuring out the representer module and reading the incoming document.

## URL Helpers

Any URL helpers from the Rails app are automatically available in representers.

```ruby
module FruitRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  link :self do
    fruit_url self
  end
end
```
To get the hyperlinks up and running, please make sure to set the right _host name_ in your environment files (config/environments):

```ruby
config.representer.default_url_options = {:host => "127.0.0.1:3000"}
```

## Testing

## Autoloading

Put your representers in `app/representers` and they will be autoloaded by Rails. Also, frequently used modules as media representers and features don't need to be required manually.


## Contributors

* [Railslove](http://www.railslove.de) and especially Michael Bumann [bumi] have heavily supported development of roar-rails ("resource :singers").

[responders]: https://github.com/plataformatec/responders
