module SingerRepresenter
  include Roar::JSON
  include Roar::Hypermedia

  property :name

  link :self do
    singer_url(name)
  end
end
