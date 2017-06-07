require "test_helper"

class ParagozTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Paragoz::VERSION
  end
end
