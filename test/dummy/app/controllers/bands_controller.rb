class Band
  attr_accessor :name
  def initialize(name=nil)
    @name = name
  end
end

class BandsController < ActionController::Base
  include Roar::Rails::ControllerAdditions
  represents :json, Band

  def show
    respond_with Band.new("Bodyjar")
  end
end
