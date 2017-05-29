require './test/test_helper'

# Tests that the default no-args config works as expected
class DefaultUsageTest < Minitest::Test
    def setup
        super(80, 81)
    end

    def test_esi_available
        url = "http://localhost:#{@esi_port}/basic/"
        puts "URL: #{url}"
        response = HTTParty.get(url)
        assert_equal(response.code, 200)
        assert(response.body.include?("If you see this text, inclusions via ESI from localhost are working."))     
    end

    def test_sandbox_available
        url = "http://localhost:#{@sandbox_port}/basic/"
        puts "URL: #{url}"
        response = HTTParty.get(url)
        assert_equal(response.code, 200)
        assert(response.body.include?('<esi:include src="sample.html"/>'))     
    end

    def test_esi_respects_location_dir_no_trailing_slash
        url = "http://localhost:#{@esi_port}/basic"
        puts "URL: #{url}"
        response = HTTParty.get(url)
        assert_equal(response.code, 200)
        assert_equal(response.request.last_uri.to_s, "http://localhost:#{@esi_port}/basic/")     
    end
end