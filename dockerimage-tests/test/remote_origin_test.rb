# frozen_string_literal: true
require './test/test_helper'

# Tests that the debug flag works as expected
class RemoteOriginTest < Minitest::Test
  def test_remote_origin_no_port_works
    start_containers('--remote_origin www.example.com')

    url = "http://#{HOST_HOSTNAME}:#{@esi_port}"
    puts "URL: #{url}"
    response = HTTParty.get(url, headers: { 'Host' => 'www.example.com' })
    assert_equal(200, response.code)
    assert(response.body.downcase.include?('example'))
  end

  def test_remote_origin_defined_port_works
    start_containers('--remote_origin www.example.com:443')

    url = "http://#{HOST_HOSTNAME}:#{@esi_port}"
    puts "URL: #{url}"
    response = HTTParty.get(url, headers: { 'Host' => 'www.example.com' })
    assert_equal(200, response.code)
    assert(response.body.downcase.include?('example'))
  end
end
