# frozen_string_literal: true
require './test/test_helper'

class DebugUsageTest < Minitest::Test
  def setup
    start_containers("--debug #{DEFAULT_APACHE_HOST}")
  end

  def test_esi_debug_works
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/basic/"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)
    assert(response.body.include?('/*********************Debugging Section*********************/'))
  end
end
