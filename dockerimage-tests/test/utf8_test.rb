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

class Utf8Test < Minitest::Test
  def test_utf8_assignment_works
    start_containers
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/advanced/utf8_assignment.html"
    puts "URL: #{url}"
    response = HTTParty.get(url)
    assert_equal(200, response.code)

    assert(response.body.include?('à'), "Value 'à' not found in output");
  end

  def test_utf8_querystring_works
    start_containers
    echoval = 'à'
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/advanced/utf8_querystring.html"
    puts "URL: #{url}"
    response = HTTParty.get(url, query: { 'value' => echoval })
    assert_equal(200, response.code)

    response.body.force_encoding('UTF-8')
    assert(response.body.include?(echoval), "Value '#{echoval}' not found in output");
  end
end
