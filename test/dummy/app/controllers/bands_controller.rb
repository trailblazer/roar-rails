Band = Struct.new(:name)

class BandsController < ActionController::Base
  include Roar::Rails::ControllerAdditions
  represents :json, Band

  def show
    respond_with Band.new("Bodyjar")
  end
end
