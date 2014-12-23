module SingerAliasRepresenter
  include Roar::JSON

  property :name, :as => :alias

end
