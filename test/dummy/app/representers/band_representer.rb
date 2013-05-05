class BandRepresenter < Roar::Decorator
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :name

  link :self do
    band_url(represented.name)
  end
end
