module Roar
  module Rails
    module PageRepresenter
      extend ActiveSupport::Concern

      def page_url(args)
        raise NotImplementedError
      end

      included do
        property :total_entries

        link :self do |opts|
          page_url(
            :page => represented.current_page,
            :per_page => represented.per_page
          )
        end

        link :next do |opts|
          page_url(
            :page => represented.next_page,
            :per_page => represented.per_page
          ) if represented.next_page
        end

        link :previous do |opts|
          page_url(
            :page => represented.previous_page,
            :per_page => represented.per_page
          ) if represented.previous_page
        end
      end
    end
  end
end
