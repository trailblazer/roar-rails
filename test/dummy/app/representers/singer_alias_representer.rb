module SingerAliasRepresenter
  include Roar::Representer::JSON

  property :name, :as => :alias

end
