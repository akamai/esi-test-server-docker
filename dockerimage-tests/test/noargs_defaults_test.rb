# frozen_string_literal: true

# Copyright 2017 Akamai Technologies, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/sandbox/basic/"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)
    assert(response.body.include?('<esi:include src="sample.html"/>'))
  end

  def test_playground_available
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/playground"
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
