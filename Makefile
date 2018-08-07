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

VERSION := $(shell ls akamai-ets_*.tar.gz | grep -Eo "([[:digit:]]\.?)+")
REPO = akamaiesi
NAME = ets-docker
FULL_NAME = ${REPO}/${NAME}

.FORCE:

all: build test dist

build: .FORCE  ## Build the docker image
	docker build -f Dockerfile -t ${FULL_NAME}:${VERSION} -t ${FULL_NAME}:latest --no-cache .

test:
	(cd dockerimage-tests && rake)

# This target generally isn't used, but is here in case you wanted to share a local build.
dist: build
	docker save ${FULL_NAME} -o ${NAME}.${VERSION}.dockerimage.tar
	gzip -f ${NAME}.${VERSION}.dockerimage.tar
