# frozen_string_literal: true
require './test/test_helper'

class HelpTest < Minitest::Test
  def test_help_text_should_show
    start_containers(80, 81, '--help', false)
    sleep 5
    assert(container_stderr.include?('For additional documentation'))
  end
end
