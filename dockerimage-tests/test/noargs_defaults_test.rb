# frozen_string_literal: true
require './test/test_helper'

# Tests that the default no-args config works as expected
class NoArgsDefaultsTest < Minitest::Test
  def setup
    start_containers
  end

  def test_esi_available
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/basic/"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)
    assert(response.body.include?('If you see this text, inclusions via ESI from localhost are working.'))
  end

  def test_sandbox_available
    url = "http://#{HOST_HOSTNAME}/sandbox/basic/"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)
    assert(response.body.include?('<esi:include src="sample.html"/>'))
  end

  def test_playground_available
    url = "http://#{HOST_HOSTNAME}/playground"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)
    assert(response.body.include?('<script>playground();</script>'))
  end

  def test_esi_respects_location_dir_no_trailing_slash
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/basic"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)
    assert_equal("http://#{HOST_HOSTNAME}:#{@esi_port}/basic/", response.request.last_uri.to_s)
  end

  def test_default_geo
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/basic/geo.html"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)

    geo_values = %w(246 US CA SANJOSE 807 7400 408 SANTACLARA 06085 37.3353 -121.8938 PST dialup)
    geo_values.each { |val| assert(response.body.include?(val), "Value #{val} not found in output") }
  end
end
