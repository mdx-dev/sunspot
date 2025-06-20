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
        return {} if @sorts.empty?

        combined_params = join_sort_params(prefix)
        @sorts.each_with_object(combined_params) do |sort, acc|
          sort.to_params.each do |param, value|
            next if param == :sort
            param = param.to_sym
            if combined_params.has_key?(param) && combined_params[param] != value
              raise(
                ArgumentError,
                "Encountered duplicate additional sort param '#{param}' with different values ('#{combined_params[param]}' vs. '#{value}')"
              )
            end

            acc[param] = value
          end
        end
      end

      private

      def join_sort_params(prefix)
        key = "#{prefix}sort".to_sym
        { key => @sorts.map { |sort| sort.to_params[:sort] } * ', ' }
      end
    end
  end
end
