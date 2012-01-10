module SingerRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :name

  link :self do
    singer_url(name)
  end
end
