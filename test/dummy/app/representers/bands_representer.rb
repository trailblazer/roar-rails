class BandsRepresenter < Roar::Decorator
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include Roar::Rails::CollectionRepresenter
end
