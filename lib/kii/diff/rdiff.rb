module Kii
  module Diff
    module Rdiff
      class Core
        attr_reader :c, :diff
        
        def initialize(rx, ry, use_hash=false)
          rx, ry = rx.to_a, ry.to_a if rx.is_a? Enumerable
          x, y = use_hash ? [hash(rx), hash(ry)] : [rx, ry]
          m, n = x.length, y.length 
          c = [aRow = ([0] * (n + 1)).freeze]
          for i in 0...m
            c[i+1] = aRow.dup
            for j in 0...n
              c[i+1][j+1] = (el x[i]) == (el y[j]) ?
                         c[i][j] + 1 : [c[i+1][j], c[i][j+1]].max
            end
          end
          @c, @x, @y, @rx, @ry = c.freeze, x, y, rx, ry
          @diff = realdiff(m-1, n-1).freeze
          @rx = @ry = @x = @y = nil
          freeze
        end

        def realdiff(i, j)
          if i >= 0 and j >= 0 and el(@x[i]) == el(@y[j])
            realdiff(i-1, j-1) + del(0, @rx[i])
          elsif j >= 0 && (i == -1 || @c[i+1][j] >= @c[i][j+1])
            realdiff(i, j-1) + del(1, @ry[j])
          elsif i >= 0 && (j == -1 || @c[i+1][j] < @c[i][j+1])
            realdiff(i-1, j) + del(-1, @rx[i])
          else
            []
          end
        end

        def el(e)
          e
        end

        def del(code, e)
          [[code, el(e)]]
        end

        def self.word_squeeze_ws(a, b, use_hash=false)
          reify a, b, ' ', use_hash
        end
        
        def self.word_save_ws(a, b, use_hash=false)
          reify a, b, /(?=\b\w)/, use_hash
        end

        private

        def hash(a)
          a.map { |x| x.hash }
        end
        
        def self.reify(a, b, re, use_hash)
          self.new a.split(re), b.split(re), use_hash
        end
      end 
    end
  end
end