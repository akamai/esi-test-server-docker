# frozen_string_literal: true
require './test/test_helper'

class GeoTest < Minitest::Test
  def test_geo_can_be_disabled
    start_containers("--geo #{DEFAULT_APACHE_HOST}:off")
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/basic/geo.html"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)

    geo_values = %w(246 US CA SANJOSE 807 7400 408 SANTACLARA 06085 37.3353 -121.8938 PST dialup)
    geo_values.each { |val| assert(!response.body.include?(val), "Value #{val} found in output when it should be absent") }
  end
end
