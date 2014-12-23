class BandRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::Hypermedia

  property :name

  link :self do
    band_url(represented.name)
  end
end
