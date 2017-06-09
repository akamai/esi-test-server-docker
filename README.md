# Akamai ETS Docker Image

## About
This container runs the Akamai Edge Side Includes Test Server. The container OS is Ubuntu 14.04 Trusty Tahr. Configuration is set via command-line arguments passed via the `docker run` command.

For more information on ESI, please visit https://yoursite.example.com/us/en/support/esi.jsp. For code samples, see http://esi-examples.akamai.com/.

By default, the servers run on ports 80 (ETS), 81 (sandbox) and 82 (ESI playground), with a hostname of localhost. ESI Debugging is not enabled by default, but Edgescape settings are, with the following defaults:
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

## Glossary
* **ESI port** - the port to which ESI-enabled requests should be proxied.
* **Sandbox/sandbox origin** - an Apache server running within the container that hosts examples by default, but can also be used to mount a local directory of ESI files for quick/easy testing.
* **Remote origin** - an upstream server for ETS to forward requests to. ESI code contained fetched from this origin will be processed by the ESI test server.
* **Edgescape** - geographical information about end users. The `--geo` flag can be used to enable/disable this for a given host. ETS uses static mocked data for these values.

## Basic usage
`docker run -t -p 8080:80 -p 8081:81 -p 8082:82 akamai-ets:latest`
* Runs the ESI server and sandbox origin.
* `-p 8080:80` and `-p 8081:81` forward ports on your local machine to open ports on the docker container. By default, the ESI server listens on port `80`, the sandbox origin listens on port `81`, and ESI playground listens on port `82``.
* ESI Debugging is disabled by default.
* Edgescape is enabled with the defaults documented above.

### ESI Debugging enabled for localhost
`docker run -t -p 8080:80 -p 8081:81 -p 8082:82 akamai-ets:latest --debug localhost`
* This will enable ESI debugging for the sandbox origin (defaults to `localhost`).

### Edgescape disabled for localhost
`docker run -t -p 8080:80 -p 8081:81 -p 8082:82  akamai-ets:latest --geo localhost:off`
* This will enable disable Edgescape for the sandbox origin (defaults to `localhost`).

### Remote origin with ESI Debugging enabled
`docker run -t akamai-ets:latest --remote_origin yoursite.example.com:443 --debug yoursite.example.com`
* This will enable ESI debugging for `yoursite.example.com`.

### Remote origin with GEO setting
`docker run -t -p 8080:80 -p 8081:81 -p 8082:82 akamai-ets:latest \
--remote_origin yoursite.example.com:443 \ --geo
yoursite.example.com:yoursite.example.com:georegion=246,country_code=US,region_code=CA, \
city=SANJOSE,dma=807,pmsa=7400,areacode=408,county=SANTACLARA,fips=06085, \
lat=37.3353,long=-121.8938,timezone=PST,network_type=dialup akamai-ets:latest`
* This will enable Edgescape for `yoursite.example.com` with the values specified in the corresponding `geo` argument.

### Multiple remote origins
`docker run -t -p 8080:80 -p 8081:81 -p 8082:82 akamai-ets:latest --remote_origin yoursite1.example.com:443 --remote_origin yoursite2.example.com --debug yoursite1.example.com --geo yoursite2.example.com:off --geo yoursite2.example.com:country_code=CA`
* This enables ETS to serve two different origins, each of which can have separate `--geo` and `--debug` settings.

## Usage Notes

### Viewing usage information from the command line
To view built-in documentation of all of the command-line arguments, run `docker run akamai-ets:latest -h`.

### Short flags
For brevity and convenience, each argument has both a long and a short flag. e.g. `--remote_origin` and `-r` are equivalent. Run `docker run akamai-ets:latest -h` for more information.

### Gotchas/limitations
The `--geo` and `--debug` flags are keyed on `hostname` only, not `hostname:port`, even though `--remote_origin` allows both. The following command will result in an error:

`docker run -t akamai-ets:latest --remote_origin yoursite.example.com:8888 --debug yoursite.example.com:8888`

The correct form is:

`docker run -t akamai-ets:latest --remote_origin yoursite.example.com:8888 --debug yoursite.example.com`

## Advanced usage

### Daemonizing to run in background
Using `docker run`'s `-d` argument (and removing `-t` or `-i`, you can run the ETS container in the background.

e.g. `docker run -d -p 8080:80 -p 8081:81 -p 8082:82 akamai-ets:latest`

To stop the container, use `docker ps` to obtain the container ID and `docker stop` or `docker kill` to make it exit. 

### Changing internal container ports - note the use of -p
It is unlikely that you will need to make use of this.

`docker run -t -p 9080:8080 -p 9081:8081 akamai-ets:latest --ets_port 8080 --sandbox_port 8081`

The ETS server can now be accessed using `curl -v -L http://localhost:9080/`.

## Networking
Users have a variety of options for how to expose ports with Docker. We've chosen to suggest port forwarding due to its compatibility and simplicity. See [this article](https://www.ctl.io/developers/blog/post/docker-networking-rules/) for more information on Docker networking options.

### Note for Docker for Mac
Docker for Mac doesn't currently support `--net host`; [you must forward ports](https://docs.docker.com/docker-for-mac/networking/#there-is-no-docker0-bridge-on-macos).

## Configuration Settings
### Primary
* `--remote_origin <hostname:port>` - hostname and port to use for an additional
  remote/upstream origin
* `--debug <hostname>` - enable ESI debugging for that hostname
* `--geo <hostname:settings>` - enable Edgescape for a hostname via mock data
    - Sample GEO flag:
      `yoursite.example.com:georegion=246,country_code=US,region_code=CA,city=SANJOSE,
      dma=807,pmsa=7400,areacode=408,county=SANTACLARA,fips=06085,lat=37.3353,
      long=-121.8938,timezone=PST,network_type=dialup`

### Secondary
It is unlikely that you will need to change these.
* `--ets_port=<port>` - internal container port for the ETS server to listen on
* `--sandbox_port=<port>` - internal container port for the sandbox (local non-ESI origin) to
  listen on


## TLS/HTTPS
The ESI test server doesn't support HTTPS for incoming connections, but remote origins using TLS are supported; just add them with port 443, e.g. `--remote_origin yoursite.example.com:443`.

## Container as origin
In some cases, you may want to specify a server running in another container as an origin. There are [diverse ways to network containers](https://docs.docker.com/engine/userguide/networking/). In the following example, a combination of Docker's `--add-host` parameter and the port in ETS' `--remote_origin` parameter are used to configure an origin hosted by another container.
* `docker run -d -p 9080:9080 -p 8082:82 -v <directory of ESI files>:/public
  redsadic/docker-http-server`
* `docker run -d -p 8080:80 -p 8081:81 -p 8082:82 akamai-ets:latest--remote_origin
  test.box:8080" --add-host test.box:<Docker host IP>`

You can then access ESI pages on that server using `curl -H 'Host: test.box' http://localhost:8080`.

## Viewing logs and modifying files
You can shell into the container using `docker exec -ti <container ID> bash`. Logs can be found in `/opt/akamai-ets/logs`.

## Mounting a directory of ESI pages
You can trivially mount HTML files containing ESI tags in the sandbox server as follows:

`docker run -t -p 8080:80 -p 8081:81 -p 8082:82 -v $(pwd)/esi_pages:/opt/akamai-ets/virtual/localhost/docs akamai-ets:latest`

If you issue requests via the ETS port (80 by default), the ESI tags will be processed. If you want to enable ESI debugging, pass the `--debug localhost` argument.

## Status page
A basic status page implemented using `mod_status` is available at `/server-status` on the sandbox server.

## Examples
A set of ESI examples can be accessed when running the container with defaults at http://localhost/esi-examples/index.html .

## Security
This software should only be used in restricted environments for testing and development. For security on public or untrusted networks, ensure that your Docker network configuration does not expose ports except to the local machine.

## License
LICENSE AGREEMENT

By downloading software ("Software") of Akamai Technologies, Inc. ("Akamai")
from this site, you agree to the terms and conditions contained in this License
Agreement (the "Agreement"). Please read this Agreement carefully before
downloading or attempting to download this Software. Akamai will license the
Software to you only if you first accept the terms of this Agreement. By
downloading the Software, you agree to these terms. If you do not agree to the
terms of this Agreement, do not download the Software. The Software includes
computer programs (machine-readable instructions, data, and related
documentation). The Software is owned by Akamai and is copyrighted and licensed
and not sold.  

1. License. You have a non-exclusive, personal and non-transferable license to
   use the Software solely in connection with Akamai EdgeSuite Services. You
   will ensure that anyone who uses the Software does so only in compliance with
   the terms of this Agreement.

2. Restrictions. You may not use, copy, modify or distribute the Software except
   as provided in this Agreement. Except as permitted by applicable law and this
   Agreement, you may not decompile, reverse engineer, disassemble, modify,
   rent, lease, loan, distribute, sublicense, or create derivative works from,
   the Software or transmit the Software over a network. You may not use or
   otherwise export the Software except as authorized by United States law and
   the laws of the jurisdiction in which the Software was obtained. In
   particular, but without limitation, none of the Software may be used or
   otherwise exported or reexported (a) into (or to a national or resident of) a
   United States embargoed country or (b) to anyone on the U.S. Treasury
   Department's list of Specially Designated Nationals or the U.S. Department of
   Commerce's Table of Denial Orders. By using the Software, you represent and
   warrant that you are not located in, under control of, or a national or
   resident of any country or on any such list.

3. No Warranty On Software. You use the Software entirely at your own risk.
Akamai is providing the Software to you "AS IS" and without warranty. You are
not entitled to any hard copy documentation, maintenance, support or updates for
the Software. AKAMAI EXPRESSLY DISCLAIMS ALL WARRANTIES RELATED TO THE SOFTWARE,
EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. AKAMAI DOES NOT WARRANT
THAT THE FUNCTIONS CONTAINED IN THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR
THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT
DEFECTS IN THE SOFTWARE WILL BE CORRECTED.  FURTHERMORE, AKAMAI DOES NOT WARRANT
OR MAKE ANY REPRESENTATIONS REGARDING THE USE OR THE RESULTS OF THE USE OF THE
SOFTWARE OR RELATED DOCUMENTATION IN TERMS OF THEIR CORRECTNESS, ACCURACY,
RELIABILITY OR OTHERWISE. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF
IMPLIED WARRANTIES, SO PORTIONS OF THE ABOVE EXCLUSION MAY NOT APPLY TO YOU.

4. Limitation Of Liability. In no event shall Akamai be liable to you for any
damages exceeding the amount paid for the Software. UNDER NO CIRCUMSTANCES,
INCLUDING NEGLIGENCE, SHALL AKAMAI BE LIABLE FOR ANY INCIDENTAL, SPECIAL,
INDIRECT OR CONSEQUENTIAL DAMAGES ARISING OUT OF OR RELATING TO THIS LICENSE,
INCLUDING, BUT NOT LIMITED TO, DAMAGES RESULTING FROM ANY LOSS OF DATA CAUSED BY
THE SOFTWARE. SOME JURISDICTIONS DO NOT ALLOW THE LIMITATION OF INCIDENTAL OR
CONSEQUENTIAL DAMAGES SO THIS LIMITATION MAY NOT APPLY TO YOU.

5. Government End Users. If you are acquiring the Software on behalf of any part
   of the United States Government, the following provisions apply. The Software
   and accompanying documentation are deemed to be "commercial computer
   software" and "commercial computer software documentation," respectively,
   pursuant to DFAR Section 227.7202 and FAR 12.212(b), as applicable. Any use,
   modification, reproduction, release, performance, display or disclosure of
   the Software and/or the accompanying documentation by the U.S. Government or
   any of its agencies shall be governed solely by the terms of this Agreement
   and shall be prohibited except to the extent expressly permitted by the terms
   of this Agreement. Any technical data provided that is not covered by the
   above provisions is deemed to be "technical data-commercial items" pursuant
   to DFAR Section 227.7015(a). Any use, modification, reproduction, release,
   performance, display or disclosure of such technical data shall be governed
   by the terms of DFAR Section 220.7015(b).

6. Controlling Law and Severability. This Agreement shall be governed by the
   laws of the United States and The Commonwealth of Massachusetts. If for any
   reason a court of competent jurisdiction finds any provision, or portion
   thereof, to be unenforceable, the remainder of this Agreement shall continue
   in full force and effect. Any dispute regarding this Agreement shall be
   resolved in either the state or federal courts in Massachusetts.

7. Complete Agreement. This Agreement constitutes the entire agreement between
   the parties with respect to the subject matter hereof and supersedes all
   prior or contemporaneous understandings regarding such subject matter. No
   amendment to or modification of this Agreement will be binding unless in
   writing.

8. Included in this software package is code from third parties.  Such code is
   licensed under its own terms and conditions which, by installing and using
   the Software you also hereby agree to abide by as follow.

Certain code licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License. You may obtain a
copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
		 
libcurl Copyright (c) 1996 - 2013, Daniel Stenberg, <daniel@haxx.se>. All rights
reserved. Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above copyright
notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD PARTY RIGHTS. IN NO EVENT
SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Except as contained in this notice, the name of a copyright holder shall not be
used in advertising or otherwise to promote the sale, use or other dealings in
this Software without prior written authorization of the copyright holder.

Your rights under this Agreement will terminate automatically without notice if
you fail to comply with any term(s) of this Agreement.

Part of the software is under:
MIT Copyright (c) 2017 News Corp Australia.