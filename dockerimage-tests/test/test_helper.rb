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

require 'minitest/autorun'
require 'httparty'
require 'open3'

module Minitest
  class Test
    IMAGE_NAME = 'akamaiesi/ets-docker:latest'
    LOCAL_MOUNT_DIR = "#{File.expand_path(__dir__)}/../html"
    REMOTE_MOUNT_DIR = '/opt/akamai-ets/virtual/localhost/docs'
    MAX_PORT_WAIT = 5 # seconds
    HOST_HOSTNAME = 'localhost'
    DEFAULT_APACHE_HOST = 'localhost'
    INTERNAL_PORT = 80

    def start_containers(args = nil, expect_startup_failure = false)
      docker_cmd = 'docker run -d -P ' \
          "-v #{LOCAL_MOUNT_DIR}:#{REMOTE_MOUNT_DIR} #{IMAGE_NAME} #{args.nil? ? '' : args}"
      puts "Docker run command: #{docker_cmd}"

      stdout_stderr, status = Open3.capture2(docker_cmd)
      unless status.success?
        msg = "Docker run exited with code #{status.to_i} and output:\n#{stdout_stderr}"
        puts msg
        fail msg
      end

      @container_id = stdout_stderr.delete("\n")

      return if expect_startup_failure

      @esi_port = host_port_for(@container_id, INTERNAL_PORT)
      wait_for_port_or_fail(HOST_HOSTNAME, @esi_port)
    rescue StandardError => e
      if `docker inspect -f {{.State.Running}} #{@container_id}`.start_with? 'false'
        puts "Container #{@container_id} wasn't running after " \
                      'port check failure.'
        puts "Container exit code was: #{`docker inspect -f {{.State.ExitCode}} #{@container_id}`}"
        puts "Container output was:\n#{`docker logs #{@container_id}`}"
      end
      puts 'Error in start_containers'
      puts e
      fail 'Error in start_containers'
    end

    def teardown
      `docker kill #{@container_id}`
      `docker rm #{@container_id}`
    rescue StandardError => e
      puts 'Error in teardown:'
      puts e
    end

    ##
    # Waits for the ports to be open, with retries in between
    def wait_for_port_or_fail(host, port)
      result = false
      3.times do
        # ensure we wait a minimum between retries
        start_time = Time.now
        result = check_port_for_http_response(host, port)
        check_time = Time.now - start_time
        break if result

        if check_time < 10
          sleep 10 - check_time
        end
      end
      return if result
      fail 'Timeout waiting for port to be open.'
    end

    def check_port_for_http_response(host, port)
      url = "http://#{host}:#{port}"
      response = HTTParty.get(url, timeout: MAX_PORT_WAIT)
      !response.code.nil?
    rescue StandardError
      false
    end

    def string_has_no_esi_tags?(str)
      str !~ /<esi:/
    end

    def container_stdout
      stdout, = Open3.capture3("docker logs #{@container_id}")
      stdout
    end

    def container_stderr
      _, stderr, = Open3.capture3("docker logs #{@container_id}")
      stderr
    end

    def host_port_for(container_id, internal_port)
      docker_port_output, docker_port_status = Open3.capture2('docker', 'port', container_id)

      unless docker_port_status.success? && !docker_port_output.empty?
        message = "Failed to get port information for container id #{container_id} and port #{internal_port}"
        puts message
        fail message
      end

      docker_port_match = docker_port_output.scan(/#{internal_port}.+:(\d+)/)

      unless docker_port_match && docker_port_match[0] && docker_port_match[0][0]
        message = "Failed to extract a port ID from the following command output: #{docker_port_output}"
        puts message
        fail message
      end

      docker_port_match[0][0]
    end
  end
end
