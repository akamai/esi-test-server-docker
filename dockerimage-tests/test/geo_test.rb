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
