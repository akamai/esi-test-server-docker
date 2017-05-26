require "minitest/autorun"
require "httparty"
require "pry-byebug"

class Minitest::Test
    IMAGE_NAME="akamai-ets:latest"
    LOCAL_MOUNT_DIR="#{File.expand_path(File.dirname(__FILE__))}/../html"
    REMOTE_MOUNT_DIR='/opt/akamai-ets/virtual/localhost/docs'
    MAX_PORT_WAIT = 5 # seconds

  def setup(esi_internal_port, sandbox_internal_port)
      @hostname = 'localhost'

      docker_cmd = "docker run -d -p #{esi_internal_port} -p #{sandbox_internal_port} -v #{LOCAL_MOUNT_DIR}:#{REMOTE_MOUNT_DIR} #{IMAGE_NAME}"
      puts "Docker run command: #{docker_cmd}"
      @container_id = `#{docker_cmd}`.gsub(/\n/, '')

      @esi_port = `docker port #{@container_id} #{esi_internal_port}`.scan(/:(\d+)/)[0][0]
      @sandbox_port = `docker port #{@container_id} #{sandbox_internal_port}`.scan(/:(\d+)/)[0][0]

      wait_for_port_or_fail(@hostname, @esi_port)
      wait_for_port_or_fail(@hostname, @sandbox_port)
  end

    def teardown
        begin
            # `docker kill #{@container_id}`
            # `docker rm #{@container_id}`
        rescue => e
            puts "Error in teardown:"
            puts e
        end
    end

    def wait_for_port_or_fail(host, port)
        result = false
        (1..3).each do
            # ensure we wait a minimum between retries
            start_time = Time.now
            result = check_port_for_http_reponse(host, port)
            check_time = Time.now - start_time
            break if result

            if check_time < 10
                sleep 10 - check_time
            end
        end
        if !result
            fail "Timeout waiting for port to be open."
        end
    end

    def check_port_for_http_reponse(host, port)
        begin
            url = "http://#{host}:#{port}"
            response = HTTParty.get(url, { timeout: MAX_PORT_WAIT });
            return !response.code.nil?
        rescue => e
            false
        end
    end
end