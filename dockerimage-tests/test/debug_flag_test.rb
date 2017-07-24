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
