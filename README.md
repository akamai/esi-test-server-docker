# Akamai ETS Docker Image

## About
This container runs the Akamai Edge Side Includes (ESI) Test Server.

![ETS diagram](https://raw.githubusercontent.com/akamai/esi-test-server-docker/master/ets-diagram.png)

The container OS is Ubuntu 14.04 Trusty Tahr. Configuration is set via command-line arguments passed via the `docker run` command.

For more information on ESI, please visit https://www.akamai.com/us/en/support/esi.jsp. For code samples, see http://esi-examples.akamai.com/.

## Glossary
* **ETS port** - port on the Docker host/machine to access processed ESI pages.
* **Sandbox origin** (or sandbox) - an Apache server running within the container that hosts ESI examples by default, but can also be used to mount a local directory of ESI files for quick and easy testing.
* **Remote origin** - an upstream server for ETS to forward requests to. ESI code fetched from this origin will be processed by the ESI Test Server.
* **Playground** - real-time, test-as-you-type ESI testing tool.
* **Edgescape** - geographical information about end users. The `--geo` flag can be used to enable or disable this for a given host (it's enabled by default). ETS uses static mocked data for these values with the following defaults:
```
georegion    = 246
country_code = US
region_code  = CA
city         = SANJOSE
dma          = 807
pmsa         = 7400
areacode     = 408
county       = SANTACLARA
fips         = 06085
lat          = 37.3353
long         = -121.8938
timezone     = PST
network_type = dialup
```

In order to access the ETS server, port 80 on the container must be exposed to the host. The host port which is bound to port 80 on the container is referred to as the **ETS port**. Documentation and ESI code samples can be accessed at `http://localhost:<ETS port>/`. The playground can be accessed at `http://localhost:<ETS port>/playground`. Settings for the sandbox origin can be set using the hostname `localhost`. Source code versions of ESI pages hosted on the sandbox origin can be accessed at `http://localhost:<ETS port>/sandbox`.

## Basic usage
`docker run -ti -p 8080:80 akamaiesi/ets-docker:latest`
* Runs the ESI server, sandbox origin, and playground.
* `-p 8080:80` - explicitly map/publish port 8080 (**ETS port**) on your local machine to port 80 on the Docker container. So, ETS server will be accessible by `http://localhost:8080/`, ESI playground by `http://localhost:8080/playground`, and the sandbox origin by `http://localhost:8080/sandbox`.
* ESI Debugging is disabled by default.
* Edgescape is enabled with the defaults documented above.

### Enable ESI Debugging for localhost
`docker run -ti -p 8080:80 akamaiesi/ets-docker:latest --debug localhost`
* This will enable ESI debugging for the sandbox origin (defaults to `localhost`).

### Disable Edgescape for localhost
`docker run -ti -p 8080:80 akamaiesi/ets-docker:latest --geo localhost:off`
* This will disable Edgescape for the sandbox origin (defaults to `localhost`).

### Remote origin with ESI Debugging enabled
`docker run -ti -p 8080:80 akamaiesi/ets-docker:latest --remote_origin yoursite.example.com:443 --debug yoursite.example.com`
* This will enable ESI debugging for a remote origin on `yoursite.example.com`. To get a processed ESI page from yoursite.example.com, add "Host: yoursite.example.com" header to request for `http://localhost:8080/my_page.html`

### Remote origin with GEO setting
`docker run -ti -p 8080:80 akamaiesi/ets-docker:latest \
--remote_origin yoursite.example.com:443 \ --geo
yoursite.example.com:yoursite.example.com:georegion=246,country_code=US,region_code=CA, \
city=SANJOSE,dma=807,pmsa=7400,areacode=408,county=SANTACLARA,fips=06085, \
lat=37.3353,long=-121.8938,timezone=PST,network_type=dialup akamaiesi/ets-docker:latest`
* This will enable Edgescape for `yoursite.example.com` with the values specified in the corresponding `geo` argument.

### Multiple remote origins
`docker run -ti -p 8080:80 akamaiesi/ets-docker:latest --remote_origin yoursite1.example.com:443 --remote_origin yoursite2.example.com --debug yoursite1.example.com --geo yoursite2.example.com:off --geo yoursite2.example.com:country_code=CA`
* This enables ETS to serve two different origins, each of which can have separate `--geo` and `--debug` settings.

## Usage Notes

### Viewing usage information from the command line
To view built-in documentation of all of the command-line arguments, run:

`docker run akamaiesi/ets-docker:latest -h`.

### Short flags
For brevity and convenience, each argument has both a long and a short flag. e.g. `--remote_origin` and `-r` are equivalent. Run `docker run akamaiesi/ets-docker:latest -h` for more information.

### Argument formatting notes
The `--geo` and `--debug` flags are keyed on `hostname` only, not `hostname:port`, even though `--remote_origin` allows both. The following command will result in an error:

`docker run -ti 8080:80 akamaiesi/ets-docker:latest --remote_origin yoursite.example.com:8888 --debug yoursite.example.com:8888`

The correct form is:

`docker run -ti 8080:80 akamaiesi/ets-docker:latest --remote_origin yoursite.example.com:8888 --debug yoursite.example.com`

## Advanced usage

### Daemonizing to run in background
Using `docker run`'s `-d` argument (and removing `-t` or `-i`), you can run the ETS container in the background, e.g:

`docker run -d -p 8080:80 akamaiesi/ets-docker:latest`

To stop the container, use `docker ps` to obtain the container ID and `docker stop` or `docker kill` to make it exit. 

## Networking
We suggest explicit port publishing and mapping due to its compatibility and simplicity. See [this article](https://www.ctl.io/developers/blog/post/docker-networking-rules/) for more information on Docker networking options.

## Configuration settings
### Primary
* `--remote_origin <hostname:port>` - hostname and port to use for an additional
  remote/upstream origin
* `--debug <hostname>` - enable ESI debugging for that hostname
* `--geo <hostname:settings>` - enable Edgescape for a hostname via mock data
    - Sample GEO flag:
    
      `--geo yoursite.example.com:georegion=246,country_code=US,region_code=CA,city=SANJOSE,
      dma=807,pmsa=7400,areacode=408,county=SANTACLARA,fips=06085,lat=37.3353,
      long=-121.8938,timezone=PST,network_type=dialup`

## Support for HTTPS
The ESI test server doesn't support HTTPS for incoming connections, but remote origins using it are supported. Add them with port 443, e.g. `--remote_origin yoursite.example.com:443`. ETS will unset the `Content-Security-Policy` response header to ensure that browsers will not upgrade ETS requests to a secure/HTTPS schema.

## Container as origin
In some cases you may want to specify a server running in another container as an origin. There are [many ways to network containers](https://docs.docker.com/engine/userguide/networking/). In this example, a combination of Docker's `--add-host` parameter and the port in ETS' `--remote_origin` parameter are used to configure an origin hosted by another container:
* `docker run -d -p 9080:8080 -v <directory of ESI files>:/public redsadic/docker-http-server`
* `docker run -d -p 8080:80 --add-host test.box:<Docker host IP> akamaiesi/ets-docker:latest --remote_origin test.box:9080 `

You can then access ESI pages on that server using `curl -H 'Host: test.box' http://localhost:8080`.

## Viewing logs and modifying files
You can shell into the container using `docker exec -ti <container ID> bash`. Logs can be found in `/opt/akamai-ets/logs`.

## Mounting a directory of ESI pages
You can trivially mount HTML files containing ESI tags in the sandbox server as follows:

`docker run -ti -p 8080:80 -v $(pwd)/my_esi_pages:/opt/akamai-ets/virtual/localhost/docs akamaiesi/ets-docker:latest`

If you issue requests via the **ETS port**, the ESI tags will be processed. If you want to enable ESI debugging, pass the `--debug localhost` argument. If you'd like to still be able to access default ETS server content (main page and ESI examples), mount your local folder as a subfolder:

`-v $(pwd)/my_esi_pages:/opt/akamai-ets/virtual/localhost/docs/my_esi_pages` 

Your pages will be available at `http://localhost:<ETS port>/my_esi_pages/`

## Disabling sandbox and/or playground
If the sandbox or playground interfere with your code, i.e. you'd like to mount your own directory of ESI pages that have `sandbox`, `server-status` folders (used by the sandbox), or `playground`, `assets`, `process` folders (used by the playground), then you can disable the sandbox with `--no_sandbox` option, and the playground with `--no_playground`. For example:

`docker run -ti -p 8080:80 -v $(pwd)/my_esi_pages:/opt/akamai-ets/virtual/localhost/docs akamaiesi/ets-docker:latest --no_playground`

Your pages at `/my_esi_pages/playground` will be accessible at `http://localhost:<ETS port>/playground`

## Status page
A basic status page implemented using Apache's `mod_status` module is available at `http://localhost:<ETS port>/server-status`.

## ESI playground
ESI playground is a real-time, test-as-you-type ESI testing tool, it's available at `http://localhost:<ETS port>/playground`.

## ESI code examples
A set of ESI examples can be accessed at `http://localhost:<ETS port>/esi-examples/index.html`.

## Other ports used by container
The ETS services run on the following Docker container ports: 81 (sandbox), 82 (ESI playground), 83 (ESI processing for sandbox), with a hostname of `localhost`.

## ETS docker test automation examples
An example of how to use the ETS docker image as part of test automation can be found in Git [here](https://github.com/akamai/esi-test-server-docker/tree/master/dockerimage-tests).

## Security
This software should only be used in restricted environments for testing and development. For security on public or untrusted networks, ensure that your Docker network configuration does not expose ports except to the local machine.

## Support
For support with Edge Side Includes or the ESI Test Server, please reach out through [standard support channels](https://www.akamai.com/us/en/support/).

To report a bug, please [create a Github issue](https://github.com/akamai/esi-test-server-docker/issues/new) or email [esi-test-server](mailto:esi-test-server@akamai.com).

To report a security vulnerability, please email [security@akamai.com](mailto:security@akamai.com). ([GPG key](https://www.akamai.com/us/en/multimedia/documents/infosec/akamai-security-general.pub))

## License
The Dockerfile and associated code samples and scripts are licensed under the Apache License 2.0.

Licenses for the products installed within the image:
* Apache HTTP Server: [Apache License 2.0](https://github.com/akamai/esi-test-server-docker/blob/master/licenses/Apache.md)
* Akamai ESI Test Server: Copyright 2017 Akamai Technologies, Inc. [Akamai License Agreement](https://github.com/akamai/esi-test-server-docker/blob/master/licenses/Akamai.md)
* libcurl: Copyright (c) 1996 - 2017, Daniel Stenberg, daniel@haxx.se, and many contributors, see the THANKS file. [MIT License](https://github.com/akamai/esi-test-server-docker/blob/master/licenses/Curl.md)
* ESI Playground: Copyright (c) 2017 News Corp Australia [MIT License](https://github.com/akamai/esi-test-server-docker/blob/master/licenses/NewsCorpAustralia.md)
