# frozen_string_literal: true
require './test/test_helper'

class ComplexArgsTest < Minitest::Test
  def test_multiple_remote_origins_separate_settings
    args = '--remote_origin www.example.com --remote_origin www.example.org ' \
      '--remote_origin esi-examples.akamai.com ' \
      '--geo esi-examples.akamai.com:country_code=JP,city=TOKYO ' \
      '--debug www.example.org'
    start_containers(args)

    url = "http://#{HOST_HOSTNAME}:#{@esi_port}"
    puts "URL: #{url}"
    response = HTTParty.get(url, headers: { 'Host' => 'www.example.org' })
    assert_equal(200, response.code)
    assert(response.body.include?('/*********************Debugging Section*********************/'))
    assert(response.body.downcase.include?('example'))

    url = "http://#{HOST_HOSTNAME}:#{@esi_port}"
    puts "URL: #{url}"
    response = HTTParty.get(url, headers: { 'Host' => 'www.example.com' })
    assert_equal(200, response.code)
    assert(response.body.downcase.include?('example'))

    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/viewsource/geo.html"
    puts "URL: #{url}"
    response = HTTParty.get(url, headers: { 'Host' => 'esi-examples.akamai.com' })
    assert_equal(200, response.code)
    assert(response.body.include?('TOKYO'))
    assert(response.body.include?('JP'))
  end
end
