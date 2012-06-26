# roar-rails

_Makes using Roar's representers in your Rails app fun._

Roar is a framework for parsing and rendering REST documents. For a better overview about representers please check the [roar repository](https://github.com/apotonick/roar#roar).

## Features

* Rendering with responders
* Parsing incoming documents
* URL helpers in representers
* Better tests
* Autoloading

## Rendering with #respond_with

roar-rails provides a number of baked-in rendering methods.

### Conventional Rendering

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

The representer name will be infered from the passed model class (e.g. a `Singer` instance gets the `SingerRepresenter`). If the passed model is a collection it will be extended using a representer. The representer name will be computed from the controller name (e.g. a `SingersController` uses the `SingersRepresenter`).

Need to use a representer with a different name than your model? You may always pass it in using the `:represent_with` option:

```ruby
respond_with singers, :represent_with => MusicianCollectionRepresenter
end
```

### Represents Configuration

If you don't want to use conventions or pass representers you can configure them on the class level using `#represents`. This will also call `respond_to` for you.

```ruby
class SingersController < ApplicationController
  represents :json, Musician
```
This will use the `MusicianRepresenter` for models and `MusiciansRepresenter` for representing collections.

Note that `#represents` also allows fine-tuning.

```ruby
class SingersController < ApplicationController
  represents :json, :entity => MusicianRepresenter, :collection => MusicianCollectionRepresenter
```

### Old API Support

If you don't want to write a dedicated representer for a collection of items (highly recommended, thou) but rather use a representer for each item, use the `:represent_items_with` option.

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

Note that it respects settings from `#represents`. It uses the same mechanics known from `#respond_with` to choose a representer.

```ruby
consume!(singer, :represent_with => MusicianRepresenter)
```

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
