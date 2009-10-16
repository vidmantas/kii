module Kii
  module Diff
    class AgeVisualization
      class AVCore < Kii::Diff::Rdiff::Core
        def el(xy)
          xy.text
        end
        def del(code, xy)
          code == '- ' ? [] : [xy]
        end
      end

      class Revision
        attr_reader :text, :timestamp

        def initialize(text, timestamp)
          @text, @timestamp = text, timestamp
        end

        def ==(rhs)
          @text == rhs.text and @timestamp == rhs.timestamp
        end

        # this factory method creates an array of 1-word nodes w/ white space
        def split
          # split into "words" but preserving white space
          @text.split(/\b(?=\s)/).map { |w| self.class.new w, @timestamp }
        end
      end

      attr_reader :rev_in, :rev_out

      def initialize(revisions)
        @rev_in = revisions
      end

      def compute
        res = []
        @rev_in.map do |r|
          res = AVCore.new(res, r.split).diff
        end
        # res is now an [] of Revision by words, so merge adjacent equal timestamps
        merge = nil
        new_result = []
        res.each do |r|
          if merge.nil?
            merge = r
          else
            if merge.timestamp == r.timestamp
              merge = Revision.new merge.text + r.text, r.timestamp
            else
              new_result << merge
              merge = r
            end
          end
        end
        new_result << merge unless merge.nil?
        @rev_out = new_result
      end

    end
  end
end