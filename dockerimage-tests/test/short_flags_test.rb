# frozen_string_literal: true
require './test/test_helper'

class ShortFlagsTest < Minitest::Test
  def test_localhost_debug_shortflag_works
    start_containers(80, 81, "-d #{DEFAULT_APACHE_HOST}")
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/basic/"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)
    assert(response.body.include?('/*********************Debugging Section*********************/'))
  end

  def test_localhost_geo_shortflag_works
    start_containers(80, 81, "-g #{DEFAULT_APACHE_HOST}:throughput=ludicrous")
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/basic/geo.html"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)
    assert(response.body.include?('ludicrous'))
  end

  def test_remote_origin_shortflag_works
    start_containers(80, 81, '-r www.example.com')
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}"
    puts "URL: #{url}"
    response = HTTParty.get(url, headers: { 'Host' => 'www.example.com' })
    assert_equal(200, response.code)
    assert(response.body.downcase.include?('example'))
  end

  def test_port_shortflags_work
    start_containers(8888, 9999, '-e 8888 -s 9999')
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)

    url = "http://#{HOST_HOSTNAME}:#{@sandbox_port}"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)
  end

  def test_help_shortflag_works
    start_containers(80, 81, '-h', false)
    sleep 5
    assert(container_stderr.include?('For additional documentation'))
  end
end
