module Kii
  module Diff
    module HTML
      SPLIT_REGEX = /(?=\s)/
      def self.diff(a, b)
        diff = Kii::Diff::Rdiff::Core.new(a.split(SPLIT_REGEX), b.split(SPLIT_REGEX)).diff
        
        # Converting [[0, "foo"], [1, "bar"], [1, "baz"]] into
        # [[0, "foo"], [1, "bar", "baz"]] (merging, so to speak).
        result = [[diff[0][0]]]
        diff.each {|state, element|
          if result[-1][0] != state
            result << [state]
          end

          result[-1] << element
        }

        result.map {|i|
          state = i[0]
          data = i[1..-1].join

          case state
          when -1
            "<del>#{data}</del>"
          when 0
            data
          when 1
            "<ins>#{data}</ins>"
          end
        }.join
      end
    end
  end
end