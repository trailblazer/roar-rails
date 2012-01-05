Musician = Struct.new(:name)

class SingersController < ActionController::Base
  def show
    singer = Musician.new("Bumi")
    render :text => singer.extend(SingerRepresenter).to_json
  end
end
