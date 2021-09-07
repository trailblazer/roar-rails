# roar-rails

_Makes using Roar's representers in your Rails app fun._

[![Build Status](https://travis-ci.org/apotonick/roar-rails.svg?branch=master)](https://travis-ci.org/apotonick/roar-rails)
[![Gem Version](https://badge.fury.io/rb/roar-rails.svg)](http://badge.fury.io/rb/roar-rails)

_roar-rails development will be discontinued in the future and we will encourage users to begin migrating to [Trailblazer](http://trailblazer.to) (and [trailblazer-rails](https://github.com/trailblazer/trailblazer-rails))._

---

Roar is a framework for parsing and rendering REST documents. For a better overview about representers please check the [roar repository](https://github.com/trailblazer/roar#roar).

Roar-rails gives you conventions and convenient access to a lot of Roar's functionality within your Rails app.

## Features

* Rendering with responders
* Parsing incoming documents
* URL helpers in representers
* Better tests
* Autoloading
* Generators

This gem works with all Rails >= 3.x.

## Prerequisites

Add it to your app's `Gemfile`.

```ruby
gem "roar-rails"
```

Note: For Rails >= 4.2, you need to add the `responders` gem, too, if you use `respond_with`. This has to be before the `roar-rails` entry in the Gemfile.

```ruby
gem "responders"
gem "roar-rails"
```

## Generators

The generator will create the representer modules in `app/representers` for you.

Here's an example.

```shell
rails g representer Band id name
```

This will create the file `app/representers/band_representer.rb` with the following content,

```ruby
  module BandRepresenter
    include Roar::JSON

    property :id
    property :name
  end
```

You can change the format (e.g. XML), and pass arbitrary options to customize the generated representer. For all available options, just run

```shell
rails g representer
```


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

If you don't want to use conventions or pass representers you can configure them on the class level using `::represents`. This will also call `respond_to` for you.

```ruby
class SingersController < ApplicationController
  represents :json, Musician
```
This will use the `MusicianRepresenter` for models and `MusiciansRepresenter` for representing collections.

Note that `::represents` also allows fine-tuning.

```ruby
class SingersController < ApplicationController
  represents :json, :entity => MusicianRepresenter, :collection => MusicianCollectionRepresenter
```

You might pass strings as representer names to `::represents`, they will be constantized at run-time when needed.

## Rendering with #render

In place of `#respond_with`, you can also use `#render` to serialize objects using representers.

```ruby
class SingersController < ApplicationController
  include Roar::Rails::ControllerAdditions
  include Roar::Rails::ControllerAdditions::Render

  def show
    singer = Singer.find_by_id(params[:id])
    render json: singer
  end
end
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


## Parsing incoming documents

In `#create` and `#update` actions it is often necessary to parse the incoming representation and map it to a model instance. Use the `#consume!` method for this.
The client must provide a `Content-Type` request header with proper MIME type to let `#consume!` know which representer to use.

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

For instance, if content type is set to `application/xml` the `consume!` call will roughly do the following.

```ruby
singer.
  extend(SingerRepresenter)
  from_xml(request.body)
```

So, `#consume!` helps you figuring out the representer module and reading the incoming document. Just like Rails, depending on the registered MIME type for `Content-type` it picks the deserialize method (e.g. `from_json` vs. `from_xml`)

It is important to provide a known content type in the request. If it is missing or not supported by the responder
`#consume!` will raise an exception `Roar::Rails::ControllerAdditions::UnsupportedMediaType`. Unless you rescue the exception the action will stop and respond with HTTP status `406 Unsupported Media Type`.

Note that `#consume!` respects settings from `#represents`. It uses the same mechanics known from `#respond_with` to choose a representer.

```ruby
consume!(singer, :represent_with => MusicianRepresenter)
```

## Using Decorators

If you prefer roar's decorator approach over extend, just go for it. roar-rails will figure out automatically which represent strategy to use. Be sure to use roar >= 0.11.17.

```ruby
class SingerRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::Hypermedia

  property :name

  link :self do
    singer_url(represented)
  end
end
```

In decorators' link blocks you currently have to use `represented` to get the actual represented model (this is `self` in module representers).

### Collections with Decorators

When using Decorators, you can include `Roar::Rails::CollectionRepresenter` to create a Representer for a collection of resources.

```ruby
class BandsRepresenter < Roar::Decorator
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include Roar::Rails::CollectionRepresenter
end

class BandRepresenter < Roar::Decorator
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :name

  link :self do
    band_url(represented.name)
  end
end

class BandsController < ActionController::Base
  include Roar::Rails::ControllerAdditions
  represents :json, Band

  def index
    bands = Bands.find(:all)

    respond_with bands
  end
end
```

This will create a collection (`bands` in this case) based on the name of the Representer, using the singular representer (BandRepresenter) to serialize each individual resource in the collection. Therefore **GET** `/bands` would give you a response similar to:

```json
{
  "bands": [
    {
      "name": "Pink Floyd",
      "links": [
        {
          "rel": "self",
          "href": "http://roar.apotomo.de/bands/1"
        }
      ]
    },
    {
      "name": "The Beatles",
      "links": [
        {
          "rel": "self",
          "href": "http://roar.apotomo.de/bands/2"
        }
      ]
    }
  ]
}
```

If you need more custom behavior and want to define your own collection, you can do it like so:

```ruby
class BandsRepresenter < Roar::Decorator
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  collection :bands, :exec_context => :decorator, :decorator => RockBand

  def bands
    represented
  end
end
```

## Passing Options

Both rendering and consuming support passing user options to the representer.

With `#respond_with`, any additional options will be passed to `to_json` (or whatever format you're using).

```ruby
respond_with @singer, :current_user => current_user
```

Same goes with `#consume!`, passing options to `from_json`.

```ruby
consume! Singer.new, :current_user => current_user
```

Note: If you pass in options to a representer, you must process them youself.  For rendering, use `:getter` in the representer.

```ruby
property :username, getter: lambda { |args| args[:current_user].name }
```

That'll render the `current_user`'s name as the `username` property.

More docs about passing and processing option can be found [here](https://github.com/apotonick/representable/#passing-options).


## URL Helpers

Any URL helpers from the Rails app are automatically available in representers.

```ruby
module FruitRepresenter
  include Roar::JSON
  include Roar::Hypermedia

  link :self do
    fruit_url self
  end
end
```
To get the hyperlinks up and running, please make sure to set the right _host name_ in your environment files (config/environments):

```ruby
config.representer.default_url_options = {:host => "127.0.0.1:3000"}
```

Attention: If you are using representers from a gem your Rails URL helpers might not work in these modules. This is due to a [loading order problem](https://groups.google.com/forum/?fromgroups#!topic/rubyonrails-core/5tG5unZ8jDQ) in Rails. As a workaround, don't require the representers in the gem but load them as late as possible, usually it works when you require in the controller. We are working on fixing that problem.

## Representing Formats Exclusively

By default, roar-rails will extend/decorate any model passed to `respond_with` for any request format. When adding roar-rails to a legacy project, you might want to restrict roar-rails' representing and fall back to the old behavior for certain formats. This can be configured both globally and on a per action basis.

To restrict representing globally to a particular format you can set the `config.representer.represented_formats` in your environment's configuration to an array of formats.  For example the following will only represent hal and json requests.

```ruby
config.representer.represented_formats = [:hal, :json]
```

The global configuration (or lack thereof) can be overridden by supplying the `:represented_formats` array when calling `respond_with`.  The following will only represent `@resource` for the hal format in the `show` action. For any other format, it will expose the resource using Rails' old behavior.


```ruby
class MyController < ApplicationController
  def show
    ...
    respond_with @resource, :represented_formats => [:hal]
  end
end
```

You can entirely suppress roar-rails in `respond_with` by passing in an empty array.

```ruby
class MyController < ApplicationController
  def show
    ...
    respond_with @resource, :represented_formats => []
  end
end
```

## Testing

## Autoloading

Put your representers in `app/representers` and they will be autoloaded by Rails. Also, frequently used modules as media representers and features don't need to be required manually.

## JSON-API

In a JSON-API environment, only one representer is written for both singular and collection resources. However, you have to configure `represents` accordingly so it knows what representer to use for collections.

```ruby
class SongsController < ApplicationController
  represents :json_api, entity: SongRepresenter, collection: SongRepresenter.for_collection
```


## Rails 4.1+ and HAL/JSON-API

**Note**: this is a temporary work-around, we're trying to fix that in Rails/roar-rails itself [May 2014].

Rails 4.1 and up expects you to manually register a global HAL or JSON-API renderer, or `respond_with` will throw an `ActionController::MissingRenderer` exception.

One fix is to add this to `config/initializers/mime_types.rb` right below `Mime::Type.register 'application/hal+json', :hal`:

```ruby
ActionController::Renderers.add :hal do |obj, options|
  self.content_type ||= Mime[:hal]
  obj
end
```

Similarly, for JSON-API, below `Mime::Type.register 'application/vnd.api+json', :json_api` add:


```ruby
ActionController::Renderers.add :json_api do |obj, options|
  self.content_type ||= Mime[:json_api]
  obj
end
```
## Contributors

* [Railslove](http://www.railslove.de) and especially Michael Bumann [bumi] have heavily supported development of roar-rails ("resource :singers").

[responders]: https://github.com/plataformatec/responders

## License

Roar-rails is released under the [MIT License](http://www.opensource.org/licenses/MIT).
