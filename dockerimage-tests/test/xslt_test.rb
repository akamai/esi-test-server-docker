# frozen_string_literal: true

# Copyright 2018 Akamai Technologies, Inc. All Rights Reserved.
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

class XsltTest < Minitest::Test
  def setup
    @test_file = '/advanced/xslt.xml'
    @param_a = '482e3f'
    @param_b = '2ce330'
    @query_string = "a=#{@param_a}&b=#{@param_b}"
    @expected_query_string = @query_string.gsub(/&/, '&amp;')

    @user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:60.0) Gecko/20100101 Firefox/60.0"
    @ua_browser = 'MOZILLA'
    @ua_version = 5
    @ua_os = 'MAC'

    @cookie_name = 'Bora Horza Gobuchul'
    @cookie_age = 314
    @cookies = ["name=#{@cookie_name}", "age=#{@cookie_age}"]
    @cookie_header = @cookies.join('; ')

    @geo_str = 'georegion=246,country_code=US,region_code=CA,city=SANJOSE,dma=807,pmsa=7400,areacode=408,county=SANTACLARA,fips=06085,lat=37.3353,long=-121.8938,timezone=PST,network_type=dialup'
    @geo_country = 'US'
    @geo_region = 'CA'

    start_containers
  end

  def request
    url = "http://#{HOST_HOSTNAME}:#{@esi_port}#{@test_file}?#{@query_string}"
    puts "URL: #{url}"

    headers = {
      'User-Agent' => @user_agent,
      'Cookie' =>     @cookie_header
    }

    response = HTTParty.get(
      url,
      headers: headers
    )

    assert_equal(200, response.code)
    response
  end

  def test_http_vars
    response = request

    assert_includes(response.body, "REQUEST_PATH: #{@test_file}")
    assert_includes(response.body, 'REQUEST_METHOD: GET')
    assert_includes(response.body, "QUERY_STRING: #{@expected_query_string}")
    assert_includes(response.body, "HTTP_COOKIE: #{@cookie_header}")
    assert_includes(response.body, "HTTP_USER_AGENT: #{@user_agent}")
  end

  def test_geo_fn
    response = request

    assert_includes(response.body, "geo(): #{@geo_str}")
    assert_includes(response.body, "geo('country_code'): #{@geo_country}")
    assert_includes(response.body, "geo('region_code'): #{@geo_region}")
  end

  def test_cookie_fn
    response = request

    assert_includes(response.body, "cookie(): #{@cookie_header}")
    assert_includes(response.body, "cookie('name'): #{@cookie_name}")
    assert_includes(response.body, "cookie('age'): #{@cookie_age}")
  end

  def test_querystring_fn
    response = request

    assert_includes(response.body, "query-string(): #{@expected_query_string}")
    assert_includes(response.body, "query-string('a'): #{@param_a}")
    assert_includes(response.body, "query-string('b'): #{@param_b}")
  end

  def test_useragent_fn
    response = request

    assert_includes(response.body, "user-agent(): #{@user_agent}")
    assert_includes(response.body, "user-agent('browser'): #{@ua_browser}")
    assert_includes(response.body, "user-agent('version'): #{@ua_version}")
    assert_includes(response.body, "user-agent('os'): #{@ua_os}")
  end
end
