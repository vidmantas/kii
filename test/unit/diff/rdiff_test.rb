require 'test_helper'

class RdiffTest < ActiveSupport::TestCase
  Core = Kii::Diff::Rdiff::Core
  
  S1 = "now is      the time for all good#{
      } men to come to the aid of their"
  S2 = "is now the right time for all #{
        }to come to their senses?"

  # run a given test both with and without token mapping.
  # It only takes an expected diff as the matrix that is produced
  # ..will vary as the optimizing wrapper evolves
  def lcsrun(form, symbols1, symbols2, answer)
    [true, false].each do |use_hash|
      assert_equal Core.send(form, symbols1, symbols2, use_hash).diff, answer, "lcsrun #{use_hash}"
    end
  end

  def test_space_preserving_split
    expected =[[1, "is "],
               [0, "now "],
               [-1, "is      "],
               [0, "the "],
               [1, "right "],
               [0, "time "],
               [0, "for "],
               [0, "all "],
               [-1, "good "],
               [-1, "men "],
               [0, "to "],
               [0, "come "],
               [0, "to "],
               [-1, "the "],
               [-1, "aid "],
               [-1, "of "],
               [-1, "their"],
               [1, "their "],
               [1, "senses?"]]

    lcsrun :word_save_ws, S1, S2, expected
  end
  def test_space_discarding_split
    expected =[[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
               [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
               [0, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
               [0, 1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3],
               [0, 1, 1, 2, 2, 3, 4, 4, 4, 4, 4, 4, 4],
               [0, 1, 1, 2, 2, 3, 4, 5, 5, 5, 5, 5, 5],
               [0, 1, 1, 2, 2, 3, 4, 5, 5, 5, 5, 5, 5],
               [0, 1, 1, 2, 2, 3, 4, 5, 5, 5, 5, 5, 5],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 6, 6, 6, 6],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 7, 7, 7],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 8, 8],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 8, 8],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 8, 8],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 8, 8],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 9]]

    assert_equal expected, (Core.word_squeeze_ws S1, S2, true).c
    assert_equal expected, (Core.word_squeeze_ws S1, S2, false).c
  end
  def test_matrix
    expected = [ [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 1, 1],
                 [0, 1, 1, 1, 1, 1, 1, 1],
                 [0, 1, 1, 2, 2, 2, 2, 2],
                 [0, 1, 1, 2, 2, 2, 2, 2],
                 [0, 1, 1, 2, 3, 3, 3, 3],
                 [0, 1, 1, 2, 3, 3, 3, 4],
                 [0, 1, 2, 2, 3, 3, 3, 4] ]

    assert_equal expected,
      (Core.new 'XMJYAUZ'.chars, 'MZJAWXU'.chars, false).c
    assert_equal expected,
      (Core.new 'XMJYAUZ'.chars, 'MZJAWXU'.chars, true).c
  end
  def test_diff
    expected = [ [-1, "X"],
                 [0, "M"],
                 [1, "Z"],
                 [0, "J"],
                 [-1, "Y"],
                 [0, "A"],
                 [1, "W"],
                 [1, "X"],
                 [0, "U"],
                 [-1, "Z"] ]

    lcsrun :new, 'XMJYAUZ'.chars, 'MZJAWXU'.chars, expected
  end
  def test_diff_middle
    expected = [
                 [0, "S"],
                 [0, "A"],
                 [0, "M"],
                 [0, "E"],
                 [-1, "X"],
                 [0, "M"],
                 [1, "Z"],
                 [0, "J"],
                 [-1, "Y"],
                 [0, "A"],
                 [1, "W"],
                 [1, "X"],
                 [0, "U"],
                 [-1, "Z"],
                 [0, "S"],
                 [0, "A"],
                 [0, "M"],
                 [0, "E"]]

    lcsrun :new, 'SAMEXMJYAUZSAME'.chars, 'SAMEMZJAWXUSAME'.chars, expected
  end
  def test_diff_middle_first_last
    s1 = 'ASAMEXMJYAUZSAMEZ'.chars
    s2 = 'BSAMEMZJAWXUSAMEY'.chars
    expected = [
                 [-1, "A"],
                 [1, "B"],
                 [0, "S"],
                 [0, "A"],
                 [0, "M"],
                 [0, "E"],
                 [-1, "X"],
                 [0, "M"],
                 [1, "Z"],
                 [0, "J"],
                 [-1, "Y"],
                 [0, "A"],
                 [1, "W"],
                 [1, "X"],
                 [0, "U"],
                 [-1, "Z"],
                 [0, "S"],
                 [0, "A"],
                 [0, "M"],
                 [0, "E"],
                 [-1, "Z"],
                 [1, "Y"]]
    lcsrun :new, s1, s2, expected
  end
  def test_null_vs_string
    s1 = ''.chars
    s2 = 'BSAMEMZJAWXUSAMEY'.chars
    expected = [
                  [1, 'B'],
                  [1, 'S'],
                  [1, 'A'],
                  [1, 'M'],
                  [1, 'E'],
                  [1, 'M'],
                  [1, 'Z'],
                  [1, 'J'],
                  [1, 'A'],
                  [1, 'W'],
                  [1, 'X'],
                  [1, 'U'],
                  [1, 'S'],
                  [1, 'A'],
                  [1, 'M'],
                  [1, 'E'],
                  [1, 'Y']
                 ]
    lcsrun :new, s1, s2, expected
  end
end
