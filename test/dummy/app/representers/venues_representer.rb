class VenuesRepresenter < Roar::Decorator
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include Roar::Rails::PageRepresenter

  collection :venues, :exec_context => :decorator, :decorator => VenueRepresenter

  def venues
    represented
  end

  def page_url(args)
    venues_url args
  end
end
