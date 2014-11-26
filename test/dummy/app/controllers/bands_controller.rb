Band = Struct.new(:name)

class BandsController < ActionController::Base
  include Roar::Rails::ControllerAdditions
  represents :json, Band

  def index
    bands = [
      Band.new("Bodyjar"),
      Band.new("Pink Floyd"),
      Band.new("The Beatles")
    ]

    respond_with bands
  end

  def show
    respond_with Band.new("Bodyjar")
  end
end
