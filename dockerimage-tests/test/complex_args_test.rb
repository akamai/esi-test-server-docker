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
