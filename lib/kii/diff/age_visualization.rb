module Kii
  module Diff
    class AgeVisualization
      attr_accessor :revisions
      attr_reader :nodes
      attr_writer :diff
      
      def compute
        create_diff_from_revisions
        create_nodes
        tag_age
      end
      
      def create_diff_from_revisions
        @diff = []
        @revisions.each do |revision|
          @diff = AVCore.new(@diff, revision.split).diff
        end
      end
      
      # Merges items in the diff with adjectant timestamps.
      def create_nodes
        merge = nil
        @nodes = []
        @diff.each do |r|
          if merge.nil?
            merge = r
          else
            if merge.timestamp == r.timestamp
              merge = Kii::Diff::AgeVisualization::Revision.new merge.text + r.text, r.timestamp
            else
              @nodes << merge
              merge = r
            end
          end
        end
        @nodes << merge unless merge.nil?
      end
      
      def tag_age
        first = @revisions[0].timestamp
        last = @revisions[-1].timestamp
        distance = last - first
        
        @nodes.each do |node|
          node.age = 100 - ((node.timestamp - first) / distance * 100).to_i
        end
      end
      
      class Revision
        attr_reader :text, :timestamp
        attr_accessor :age

        def initialize(text, timestamp)
          @text, @timestamp = text, timestamp
        end

        def ==(rhs)
          @text == rhs.text and @timestamp == rhs.timestamp
        end

        # this factory method creates an array of 1-word nodes w/ white space
        def split
          # split into "words" but preserving white space
          @text.split(/(?=\s)/).map { |w| self.class.new w, @timestamp }
        end
      end
      
      class AVCore < Kii::Diff::Rdiff::Core
        def el(xy)
          xy.text
        end
        def del(code, xy)
          code == '- ' ? [] : [xy]
        end
      end
    end
  end
end