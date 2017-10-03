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

class GzipTest < Minitest::Test
  def setup
    `pushd #{__dir__}; docker-compose up -d; popd`
    @esi_port = `docker port gzip_ets_1`.scan(/#{INTERNAL_PORT}.+:(\d+)/)[0][0]
    wait_for_port_or_fail(HOST_HOSTNAME, @esi_port)
  end

  def test_gzip_from_origin_supported
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}/gzip.html"
    puts "URL: #{url}"

    ua_to_expect = Random.new_seed.to_s
    response = HTTParty.get( url, headers: { 'Accept-Encoding' => 'deflate, gzip', 'Host' => 'origin', 'User-Agent' => ua_to_expect })
    assert_equal(200, response.code)

    assert(string_has_no_esi_tags?(response.body), "ESI wasn't processed.")
    assert(response.body.include?('hello'), "Value 'hello' not found in output");

    nginx_logs = `docker logs gzip_origin_1`.lines
    matching_lines = nginx_logs.select do |line|
      line.include?(ua_to_expect) && line.include?('deflate, gzip')
    end

    assert(matching_lines.length == 1, "Didn't find matching log lines for a request with gzip enabled")
  end

  def teardown
    `pushd #{__dir__}; docker-compose stop; popd`
  end
end
