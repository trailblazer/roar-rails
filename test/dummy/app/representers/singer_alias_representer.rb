module SingerAliasRepresenter
  include Roar::Representer::JSON

  property :name, :from => :alias

end
