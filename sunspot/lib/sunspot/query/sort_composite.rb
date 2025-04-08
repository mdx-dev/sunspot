module Sunspot
  module Query
    # 
    # The SortComposite class encapsulates an ordered collection of Sort
    # objects. It's necessary to keep this as a separate class as Solr takes
    # the sort as a single parameter, so adding sorts as regular components
    # would not merge correctly in the #to_params method.
    #
    class SortComposite #:nodoc:
      def initialize
        @sorts = []
      end

      # 
      # Add a sort to the composite
      #
      def <<(sort)
        @sorts << sort
      end

      # 
      # Combine the sorts into a single sort-param by joining them and add
      # possible custom additional params
      #
      def to_params(prefix = "")
        unless @sorts.empty?
          key = "#{prefix}sort".to_sym
          combined_params = join_sort_params(key)
          @sorts.each do |sort|
            sort.to_params.each do |param, value|
              next if param == :sort
              param = param.to_sym
              if combined_params.has_key?(param) && combined_params[param] != value
                raise(
                  ArgumentError,
                  "Encountered duplicate additional sort param '#{param}' with different values ('#{combined_params[param]}' vs. '#{value}')"
                )
              end

              combined_params[param] = value
            end
          end

          combined_params
        else
          {}
        end
      end

      private

      def join_sort_params(key)
        { key => @sorts.map { |sort| sort.to_params[:sort] } * ', ' }
      end
    end
  end
end
