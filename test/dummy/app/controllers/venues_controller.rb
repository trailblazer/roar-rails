Venue = Struct.new(:name)

class VenuesController < ActionController::Base
  include Roar::Rails::ControllerAdditions
  represents :json, Venue

  def index
    venues = [
      Venue.new("Red Rocks"),
      Venue.new("The Gorge"),
      Venue.new("Jazz Club")
    ]

    if defined? WillPaginate
      venues = venues.paginate(
        :page => params[:page],
        :per_page => params[:per_page]
      )
    elsif defined? Kaminari
      venues = Kaminari
        .paginate_array(venues)
        .page(params[:page])
        .per(params[:per_page])
    end

    respond_with venues
  end

  def show
    respond_with Venue.new("Red Rocks")
  end
end
